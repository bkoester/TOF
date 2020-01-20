#Notes:
#1) This is set up to run on the LARC student-course table "sc", and student-record table "sr" 
#   formatted as a tibble (sc <- as_tibble(sc)).
#2)  But, it works on any student-course table (each row contains a student-course)
#
#Required columns in the SC table
#STDNT_ID: an integer particular to a student
#CRSE_CMPNT_CD:
#UNITS_ERND_NBR: credits received in class.
#
#Returns the "sr" table with an ROE column.
#####################

range_of_experience_tidy <- function(sr,sc)
{
  #compute the total credits per student
  aa <- sc %>% group_by(STDNT_ID) %>% 
               mutate(TOT_CREDITS=sum(UNITS_ERND_NBR)) %>% ungroup()
  
  #compute the credits by format for each student
  aa <- aa %>% group_by(STDNT_ID,CRSE_CMPNT_CD) %>% 
               mutate(FMT_CREDITS=sum(UNITS_ERND_NBR)) %>% ungroup()
  
  #compute the fraction of credits in each format
  aa <- aa %>% distinct(STDNT_ID,CRSE_CMPNT_CD,.keep_all=TRUE) %>% 
        mutate(FMT_FRAC=FMT_CREDITS/TOT_CREDITS)
  
  #now get the maximum fraction for each student. 
  #Lower means a better range.
  aa <- aa %>% group_by(STDNT_ID) %>% mutate(ROE=max(FMT_FRAC)) %>% ungroup()
  
  #now clean it up and merge with the student record
  aa <- aa %>% distinct(STDNT_ID,ROE)
  
  sr <- sr %>% left_join(aa)
    
  return(sr)
  
}