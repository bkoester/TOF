#this currently computes course-wise "demographic" and "major" diversity
#these might be aggegated into an average per student.
course_diversity <- function(sc,sr)
{
  tab <- all_diversity(sr,sc)
  tab <- tab %>% select(-c('TERM_SHORT_DES'))
  sc  <- sc %>% left_join(tab,by=c('TERM_CD','SBJCT_CD','CATLG_NBR','CLASS_NBR'))
  
  sum <- sc %>% filter(grepl("^U",PRMRY_CRER_CD)) %>% group_by(STDNT_ID) %>% 
                summarize(MEAN_DEMO_DIV=mean(DEMO_DIV,na.rm=TRUE))
  
  sr <- sr %>% left_join(sum)
  
  return(sr)
  
}


all_diversity <- function(sr,sc)
{
  tempM <- categorical_course_diversity(sr,sc,TYPE='MAJOR')
  tempD <- categorical_course_diversity(sr,sc,TYPE='DEMO')
  
  tempM <- tempM %>% mutate(MAJOR_DIV=COURSE_DIV) %>% select(-COURSE_DIV)
  tempD <- tempD %>% mutate(DEMO_DIV=COURSE_DIV) %>% select(-c(COURSE_DIV,SBJCT_CD,CATLG_NBR,N))
  
  out <- left_join(tempM,tempD)
  tm  <- sc %>% group_by(TERM_CD,TERM_SHORT_DES) %>% tally()
  out <- left_join(out,tm) %>% select(-n)
  
  
  return(out)
  
}


categorical_course_diversity <- function(sr,sc,TYPE='MAJOR')
{
 library(tidyverse)
 #sc <- read_tsv("/Users/bkoester/Box Sync/LARC.WORKING/BPK_LARC_STUDENT_COURSE_20190529.tab")
 #sr <- read_tsv("/Users/bkoester/Box Sync/LARC.WORKING/BPK_LARC_STUDENT_RECORD_20190529.tab") 

 sc <- sc %>% filter((as.numeric(CATLG_NBR) < 500) & grepl("^U",PRMRY_CRER_CD))
  
 if (TYPE == 'MAJOR'){sr  <- sr %>% drop_na(UM_DGR_1_MAJOR_1_DES)}
 if (TYPE == 'DEMO') {sr  <- code_demography(sr); sr <- sr %>% mutate(UM_DGR_1_MAJOR_1_DES = DEMCAT)}
 print(names(sr))
 
 DEG <- sr %>% group_by(UM_DGR_1_MAJOR_1_DES) %>% select(UM_DGR_1_MAJOR_1_DES) %>% distinct()
 N   <- length(DEG$UM_DGR_1_MAJOR_1_DES)
 DEG <- add_column(DEG,IND=c(1:N))
 
 sr  <- left_join(sr,DEG)
 srsub  <- sr %>% select(STDNT_ID,UM_DGR_1_MAJOR_1_DES)#,STDNT_GNDR_SHORT_DES,
                         #STDNT_ETHNC_GRP_SHORT_DES,
                         #FIRST_GEN,STDNT_CTZN_STAT_CD,LOWINC)
 sc  <- left_join(sc,srsub)
 
 CLASS_NBR <- sc %>% group_by(CLASS_NBR,TERM_CD,UM_DGR_1_MAJOR_1_DES) %>% count() %>% ungroup()
 
 CLASS_NBR <- CLASS_NBR %>% group_by(CLASS_NBR,TERM_CD) %>% summarize(COURSE_DIV=(sum(n^2)/sum(n)^2)^(1/(1-2)))
 
 scsm <- sc %>% select(CLASS_NBR,TERM_CD,SBJCT_CD,CATLG_NBR) %>% 
                group_by(CLASS_NBR,TERM_CD) %>% mutate(N=n()) %>% 
                distinct(CLASS_NBR,TERM_CD,SBJCT_CD,CATLG_NBR,.keep_all=TRUE)

 
 out <- CLASS_NBR %>% left_join(scsm,by=c("CLASS_NBR"="CLASS_NBR","TERM_CD"="TERM_CD"))
 
 return(out) 
  
}

#compute_demographic_diversity <- function(sr,sc)
#{#
#
#  sc <- sc %>% filter(as.numeric(CATLG_NBR) < 500 & grepl("^U",PRMRY_CRER_CD))
#  
#  sr  <- code_demography(sr)
# 
#  srsub  <- sr %>% select(STDNT_ID,DEMCAT)
#  sc  <- left_join(sc,srsub)
# }

#create full demography coding system. 
#this assigns a unique number to each combination of the variables
#and then merges this with the student record
code_demography <- function(sr)
{
    
  sr <- sr %>% mutate(LOWINC=ifelse(MEDNUM < 40000,1,0))
 
  #View(sr)
  
  ss <- sr %>% group_by(STDNT_GNDR_SHORT_DES,STDNT_ETHNC_GRP_SHORT_DES,
                        FIRST_GEN,STDNT_CTZN_STAT_CD,LOWINC) %>% tally() %>% 
                        arrange(desc(n)) 
  N  <- dim(ss)[1]
  ss <- ss %>% add_column(DEMCAT=1:N) 
                        
  sr <- sr %>% left_join(ss)
  
  return(sr)
  
  
}
