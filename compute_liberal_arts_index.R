compute_liberal_arts_index <- function(out)
{
  
  #index within cohort and major
  out <- out %>% group_by(FIRST_TERM_ATTND_CD,UM_DGR_1_MAJOR_1_DES)
  index <- rank_and_index(out)
  out <- out %>% ungroup() %>% mutate(LAI_COHORT_MAJOR=index)
    
  #Now compute it relative to the COLLEGE for a given COHORT
  out <- out %>% group_by(FIRST_TERM_ATTND_CD,PRMRY_CRER_CD)
  index <- rank_and_index(out) 
  out <- out %>% ungroup()%>% mutate(LAI_COHORT_COLLEGE=index) 
  
  #Now compute it relative to the DIVISION for a given COHORT
  out <- out %>% group_by(FIRST_TERM_ATTND_CD,DIVISION)
  index <- rank_and_index(out) 
  out <- out %>% ungroup()%>% mutate(LAI_COHORT_DIVISION=index)
  
  #Finally compute it relative to the UNIVERSITY for a given COHORT. This seems to be the most interesting
  out <- out %>% group_by(FIRST_TERM_ATTND_CD)
  index <- rank_and_index(out) 
  out <- out %>% ungroup()%>% mutate(LAI_COHORT=index)
  
  return(out)
  
}

rank_and_index <- function(out)
{
  out <- out %>% mutate(ACADPERFORMANCE = percent_rank(SFE),
       DIFF = 1-percent_rank(EFFORT),NETDIV = percent_rank(MEAN_MAJOR_DIV), 
       SUBDIV = percent_rank(BREADTH),DEEP = percent_rank(DEPTH),
       DEMO_DIV = percent_rank(MEAN_DEMO_DIV),SF=1-percent_rank(SF_RATIO),
       FMT1FRAC = 1- percent_rank(ROE),N = n())
  
index <- (out$ACADPERFORMANCE+out$DIFF+out$NETDIV+out$SUBDIV+out$DEEP+out$DEMO_DIV+out$SF+out$FMT1FRAC)/8

#rescale to 1
mini <- min(index,na.rm=TRUE)
index <- index-mini
maxi <- max(index,na.rm=TRUE)
index <- index/maxi

return(index)

}