compute_student_faculty <- function(sr,sc)
{
  sc <- sc %>% group_by(CRSE_ID_CD,CLASS_NBR,TERM_CD) %>% mutate(N=n()) %>% ungroup()
  sc <- sc %>% group_by(STDNT_ID) %>% summarize(SF_RATIO=sum(N*UNITS_ERND_NBR)/sum(UNITS_ERND_NBR),na.rm=TRUE)
  sc <- sc %>% select(STDNT_ID,SF_RATIO)
  
  sr <- sr %>% left_join(sc)
  return(sr)
  
}