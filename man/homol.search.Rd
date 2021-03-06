\name{homol.search}
\alias{homol.search}

\title{
Homologue series extraction from LC-MS data.
}
\description{
Dynamic programming algorithm for unsupervised detection of homologue series in LC-(HR)MS data.
}
\usage{
homol.search(peaklist,isotopes,	elements=c("C","H","O"),use_C=FALSE,minmz=5,
maxmz=120,minrt=-2,maxrt=2,ppm=TRUE,mztol=3.5,rttol=0.5,minlength=5,
mzfilter=FALSE,vec_size=3E6,mat_size=3,R2=.98,spar=.45,plotit=FALSE,deb=0)
}

\arguments{
  \item{peaklist}{
	Dataframe of picked LC-MS peaks with three numeric columns for (a) m/z, (b) intensity and (c) retention time, such as \code{\link[nontarget]{peaklist}}.
}

  \item{isotopes}{
	Dataframe \code{\link[enviPat]{isotopes}}
}

  \item{elements}{ 
  FALSE or chemical elements in the changing units of the homologue series, e.g. c("C","H") for alkane chains. Used to restrict search.
}

  \item{use_C}{
	For \code{elements}: take element ratio to C-atoms into account? Used to restrict search.
}

  \item{minmz}{
	Defines the lower limit of the m/z window to search homologue series peaks, relative to the m/z of the one peak to search from. Absolute m/z value [u]. 
}

  \item{maxmz}{
	Defines the upper limit of the m/z window to search homologue series peaks, relative to the m/z of the one peak to search from. Absolute m/z value [u]. 
}

  \item{minrt}{
	Defines the lower limit of the retention time (RT) window to look for other homologue peaks, relative to the RT of the one peak to search from, i.e., RT+minrt.
	For decreasing RT with increasing HS mass, use negative values of minrt.
}

  \item{maxrt}{
	Defines the upper limit of the RT window to look for other homologue peaks, relative to the RT of the one peak to search from, i.e., RT+maxrt. See \code{minrt}.
}

  \item{ppm}{
	Should \code{mztol} be set in ppm (\code{TRUE}) or in absolute m/z [u] (\code{FALSE})?
}

  \item{mztol}{
	m/z tolerance setting: +/- value by which the m/z of a peak may vary from its expected value. If parameter \code{ppm=TRUE} (see below) given in ppm, otherwise, if \code{ppm=FALSE}, in absolute m/z [u]. 
}

  \item{rttol}{
	Retention time (RT) tolerance by which the RT between two adjacent pairs of a homologue series is allowed to differ. Units as given in column 3 of peaklist argument, e.g. [min].
}

  \item{minlength}{
	Minimum number of peaks in a homologue series.
}

  \item{mzfilter}{
	Vector of numerics to filter for homologue series with specific m/z differences of their repeating units, given the tolerances in \code{mztol}. Mind charge z!
}

  \item{vec_size}{
	Vector size. Ignore unless a relevant error message is printed (then try to increase size).
}


  \item{mat_size}{
	Matrix size for recombining, multiple of input tuples. Ignore unless a relevant error message is printed (then try to increase size).
}

  \item{R2}{
  FALSE or 0<numeric<=1. Coefficient of determination for cubic smoothing spline fits of m/z versus retention time; homologue series with lower R2 are rejected. See \code{\link[stats]{smooth.spline}}.
}

  \item{spar}{
	Smoothing parameter, typically (but not necessarily) in (0,1]. See \code{\link[stats]{smooth.spline}}.
}

  \item{plotit}{
	Logical FALSE or 0<integer<5. Intermediate plots of nearest neigbour paths, spline fits of individual homologues series >=\code{minlength}, clustered HS pairs, etc . 
}

  \item{deb}{
	Debug returns, ignore.
}

}

\details{
A dynamic programming approach is used to extract series of peaks that differ in constant m/z units and smooth changes in their retention time within bounds of mass defect changes. 
First, a nearest neighbour path through a kd-tree representation of the data is used to extract all feasible peak triplets. 
These triplets are then combined to all plausible n-tupels in n-3 steps. At each such step, each newly formed n-tupel is checked for smooth changes of RT with increasing m/z of
the homologues, using cubic splines and a R2-based threshold of the model fit. 
}

\note{
Arguments \code{isotopes} and \code{elements} are needed to limit intermediate numbers of m/z differences to screen over, based on feasible changes in mass defect. 
Similarly, intermediate numbers are also limited by the retention time and m/z windows defined by \code{minmz/maxmz} and \code{minrt/maxrt/rttol}, respectively. 
The latter are always set relative to the individual RT and m/z values of the peaks to be searched from. 
Overall, these parameters must be chosen carefully to avoid a combinatorial explosion of triplet m/z differences, leading to slow computation, memory problems or senseless results.

Values for \code{spar} and \code{R2} have to be adjusted for different chromatographic settings; the smoothing spline fits are used to eliminate homologue series candidates with erratic RT-behaviour.
Spline fits at >=\code{minlength} can be viewed by \code{plotit=2}.

Peak IDs refer to the order in which peaks are provided. Different IDs exist for adduct groups, isotope pattern groups, grouped homologue series (HS) peaks 
and homologue series cluster. Yet other IDs exist for the individual components (see note section of \code{\link[nontarget]{combine}}).

Here, IDs of homologue series group are given both in the function output \code{homol[[1]]}, \code{homol[[3]]} and \code{homol[[6]]}, with one homologue series stating one group of interrelated peaks.
}

\section{Warning}{
The \code{rttol} argument of \code{\link[nontarget]{homol.search}} must not be mixed with that of \code{\link[nontarget]{pattern.search}} or \code{\link[nontarget]{pattern.search2}}.
}
\value{

List of type homol with 6 entries 

\item{homol[[1]]}{\code{Homologue Series}. Dataframe with peaks (\code{mass},\code{intensity},\code{rt},\code{peak ID}) and their homologue series relations (\code{to ID},\code{m/z increment},\code{RT increment}) within
different homologue series (\code{HS IDs},\code{series level}). Last column \code{HS cluster} states HS clusters into which a peak was assigned via its HS.}
\item{homol[[2]]}{\code{Parameters}. Parameters used.}
\item{homol[[3]]}{\code{Peaks in homologue series}. Dataframe listing all peaks (\code{peak IDs}) per homologue series (\code{HS IDs}), the underlying mean m/z & RT increments 
(\code{m/z increments}, \code{RT increments}) and the minimum and maximum RT changes between individual peaks of the series.}
\item{homol[[4]]}{\code{m/z restrictions used}. See function argument \code{mzfilter}.}
\item{homol[[5]]}{\code{Peaks per level}. List of peak IDs per level in the individual series.}
\item{homol[[6]]}{Ignore. List with superjacent HS IDs per group - for set\code{deb=c(3,...)} }
}

\author{
Martin Loos
}
\seealso{
	\code{\link[nontarget]{rm.sat}}
	\code{\link[enviPat]{isotopes}}
	\code{\link[nontarget]{peaklist}}
	\code{\link[nontarget]{plothomol}}
}


\examples{
\donttest{
data(peaklist);
data(isotopes)
homol<-homol.search(
	peaklist,
	isotopes,	
	elements=c("C","H","O"),
	use_C=TRUE,
	minmz=5,
	maxmz=120,
	minrt=-.5,
	maxrt=2,
	ppm=TRUE,
	mztol=3.5,
	rttol=0.5,
	minlength=5,
	mzfilter=FALSE,
	vec_size=3E6,
	mat_size=3,
	spar=.45,
	R2=.98,
	plotit=FALSE
)	
plothomol(homol);
}
}