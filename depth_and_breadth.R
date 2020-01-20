#this take the student course and student record tables
#the student record table is used only to be amended to, and not for any calculations
#the student course table needs:
#1) STDNT_ID
#2) SBCJT_CD
#3) UNITS_ERND_NBR
#4) CATLG_NBR
depth_and_breadth <- function(sr,sc)
{
  
  #count the number of courses in each subject category for each student
  data <- sc %>% group_by(STDNT_ID,SBJCT_CD) %>% 
          mutate(nsubcat=n()*sum(UNITS_ERND_NBR)) %>% ungroup()
  data <- data %>% distinct(STDNT_ID,SBJCT_CD,nsubcat)
  
  #and compute the diveristy index for each student
  data <- data %>% group_by(STDNT_ID) %>% 
          summarize(BREADTH=(sum(nsubcat^2)/sum(nsubcat)^2)^(1/(1-2)))
  
  sr <- left_join(sr,data)
  
  #and the catalog depth
  data <- sc %>% group_by(STDNT_ID) %>% 
          summarize(DEPTH=sum(as.numeric(CATLG_NBR)*UNITS_ERND_NBR)/sum(UNITS_ERND_NBR)) %>%
          select(STDNT_ID,DEPTH) %>% distinct(STDNT_ID,.keep_all=TRUE)
  sr  <- left_join(sr,data)
  return(sr)
  
}