run_all_liberal_arts <- function(sr,sc)
{
 library(tidyverse)
 PATH_TO_CODE <- '/Users/bkoester/Google Drive/code/Mellon/TOF/'
 PATH_TO_DATA <- '/Users/bkoester/Box\ Sync/LARC.WORKING/'
  
 #read in the two tables
 #sr <- read_tsv(str_c(PATH_TO_DATA,'BPK_LARC_STUDENT_RECORD_20190924.tab'))
 #sc <- read_tsv(str_c(PATH_TO_DATA,'BPK_LARC_STUDENT_COURSE_20190924.tab'))
 
 #source all the code
 source(str_c(PATH_TO_CODE,'range_of_experience_tidy.R'))
 source(str_c(PATH_TO_CODE,'student_course_fixed_effect.R'))
 source(str_c(PATH_TO_CODE,'network_diversity.R'))
 source(str_c(PATH_TO_CODE,'depth_and_breadth.R'))
 source(str_c(PATH_TO_CODE,'course_diversity.R'))
 source(str_c(PATH_TO_CODE,'compute_liberal_arts_index.R'))
 
 #select the students we'll be using for Michigan
 #1) only undergrads
 #2) admitted at FALL 1998 (TERM_CD == 1210) or later
 sr <- sr %>% filter(grepl("^U",PRMRY_CRER_CD) & FIRST_TERM_ATTND_CD >= 1210) %>% 
       select(-c(count,natsci,socsci,engin,human))
 
 #select the courses
 #1) only those taken as undergrad standing
 #2) only those taken for a grade
 #3) omitting withdraws
 #4) recode the business school grade point bump.
 sc <- sc %>% filter(as.numeric(CATLG_NBR) < 500 & grepl("^U",PRMRY_CRER_CD) & 
                     CRSE_GRD_OFFCL_CD != 'W')
 
 #4) recode the business school (+) grade point bump and A+ cheat
 #ok, LARC has already taken care of this.
 
 sr <- range_of_experience_tidy(sr,sc)
 sr <- student_course_fixed_effect(sr,sc,tol=0.01)
 sr <- depth_and_breadth(sr,sc)
 sr <- course_diversity(sr,sc)
 sr <- compute_student_faculty(sr,sc)
 sr <- compute_liberal_arts_index(sr)  

 write_tsv(sr,'/Users/bkoester/Box Sync/TOF Tables/tof_student_record_Jan_2020.tsv')
 
 return(sr)
 
  
}

check_liberal_arts <- function(out)
{
  p <- out %>% filter(grepl("^FA",FIRST_TERM_ATTND_SHORT_DES)) %>% 
               group_by(FIRST_TERM_ATTND_CD,DIVISION) %>% 
               summarize(mnSFE=mean(SF_RATIO,na.rm=TRUE),
               se=sd(SF_RATIO,na.rm=TRUE)/sqrt(n())) %>% 
               ggplot(aes(x=FIRST_TERM_ATTND_CD,y=mnSFE))+
               geom_point(aes(color=DIVISION))+
               geom_errorbar(aes(color=DIVISION,ymin=mnSFE-se,ymax=mnSFE+se))
  print(p)
  
}