#include <Rcpp.h>
#include "mosaic.h"
#include "zygote.h"
#include "HBD_at_point.h"
#include "segments.h"
/* 
 * calcul des segments HBD
 */


namespace mozza {

// segments partagés HBD par les deux haplotypes du zygote
segments HBD_segments(zygote & Z);

}
