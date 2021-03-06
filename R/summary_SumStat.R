#' Summarize a SumStat object.
#'
#' \code{summary.SumStat} is used to summarize results obtained from function
#' \code{\link{SumStat}}. The output includes effective sample sizes and tables for balance statistics.
#'
#' @param object a \code{SumStat} object obtained with the \code{\link{SumStat}} function.
#' @param weighted.var logical. Indicate whether the propensity score weighted variance should be used in calculating the balance metrics. Default is \code{TRUE}.
#' @param metric a chatacter indicating the type of balance metrics. \code{"ASD"} refers to the pairwise absolute standardized difference and \code{"PSD"} refers to the population standardized difference. Default is \code{"ASD"}.
#' @param ... further arguments passed to or from other methods.
#'
#' @details  For \code{metric}, the two options \code{"ASD"} and \code{"PSD"} are defined in Li and Li (2019)
#' for the general family of balancing weights. Similar definitions are also given in McCaffrey et al. (2013)
#' for inverse probability weighting. \code{weighted.var} specifies whether weighted or unweighted variance
#' should be used in calculating ASD or PSD. An example of weighted variance with two treatment groups is given in
#' Austin and Stuart (2015). For more than two treatment groups, the maximum of ASD (across all pairs of treatments)
#' and maximum of PSD (across all treatments) are calcualted, as explained in Li and Li (2019).
#'
#' @return A list of tables containing effective sample sizes and balance statistics on covariates
#' for specified propensity score weighting schemes.
#'
#' \describe{
#' \item{\code{ effective.sample.size}}{a table of effective sample sizes. This serves as a conservative measure to
#' characterize the variance inflation or precision loss due to weighting, see Li and Li (2019).}
#'
#' \item{\code{ unweighted}}{A table summarizing mean, variance by treatment groups, and standardized mean difference.}
#'
#' \item{\code{ ATE}}{If \code{"ATE"} is specified, this is a data table summarizing mean, variance by treatment groups,
#' and standardized mean difference under inverse probability weighting.}
#'
#' \item{\code{ ATT}}{If \code{"ATT"} is specified, this is a data table summarizing mean, variance by treatment groups,
#' and standardized mean difference under the ATT weights.}
#'
#' \item{\code{ ATO}}{If \code{"ATO"} is specified, this is a data table summarizing mean, variance by treatment groups,
#' and standardized mean difference under the (generalized) overlap weights.}
#'
#' }
#'
#' @references
#'
#' McCaffrey, D. F., Griffin, B. A., Almirall, D., Slaughter, M. E., Ramchand, R. and Burgette, L. F. (2013).
#' A tutorial on propensity score estimation for multiple treatments using generalized boosted models.
#' Statistics in Medicine, 32(19), 3388-3414.
#'
#' Austin, P.C. and Stuart, E.A. (2015). Moving towards best practice when using inverse probability of treatment weighting (IPTW) using the propensity score to estimate causal treatment effects in observational studies.
#' Statistics in Medicine, 34(28), 3661-3679.
#'
#' Li, F., Li, F. (2019). Propensity score weighting for causal inference with multiple treatments.
#' The Annals of Applied Statistics, 13(4), 2389-2415.
#'
#' @export
#'
#' @examples
#' ## For examples, run: example(SumStat).
#' @importFrom  stats binomial coef cov formula glm lm model.matrix plogis poisson predict qnorm quantile sd
#' @importFrom  utils capture.output combn
#' @importFrom  graphics hist legend
summary.SumStat<-function(object,weighted.var=TRUE,metric="ASD",...){

  #extract object info
  wt_list<-colnames(object$ess)[-1]
  ncate<-length(unique(object$ps.weights$zindex))
  metric<-toupper(metric)

  if (metric!="ASD" && metric!="PSD"){
    cat("metric argument unrecognized, 'ASD' calculated instead.","\n")
    metric="ASD"
  }

  output<-function(target){

    if (metric=="ASD"){
        if (weighted.var==TRUE)
        { vm<-target$vres
          SMD<-apply(abs(target$ASD.weighted.var),1,max)
        }else{
          vm<-target$vres0
          SMD<-apply(abs(target$ASD.unweighted.var),1,max)
        }
    } else{
        if (weighted.var==TRUE)
        { vm<-target$vres
          SMD<-apply(abs(target$PSD.weighted.var),1,max)
        }else{
          vm<-target$vres0
          SMD<-apply(abs(target$PSD.unweighted.var),1,max)
        }
    }
    return(cbind(target$mres,vm,SMD))
  }

  output_sumsumstat<-list(effective.sample.size=object$ess,unweighted=output(object$unweighted.sumstat))

  for (i in 1:length(wt_list))
  {   wt<-paste0(wt_list[i],".sumstat",collapse = "")
      target<-object[[wt]]
      output_sumsumstat[[wt_list[i]]]<-output(target)
  }

  class(output_sumsumstat)<-'SumSumStat'
  output_sumsumstat
}


