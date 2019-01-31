compute_cohort_major_statistics<- function(sr,sc,CTERM=6.0)
{
  
  sc <- term_count(sr,sc)
  
  #library(tidyverse) 
  #sc <- read_tsv("/Users/bkoester/Box Sync/LARC.WORKING/BPK_LARC_STUDENT_COURSE_20180718.tab")
  #sr <- read_tsv("/Users/bkoester/Box Sync/LARC.WORKING/BPK_LARC_STUDENT_RECORD_20180718.tab")
  
  START_TERM <- 1560
  END_TERM   <- 1810
  
  sr <- sr %>% replace_na(list(UM_DGR_1_MAJOR_1_DES="NONE",DIVISION="NONE"))
  sr <- sr %>% mutate(UM_DGR_1_MAJOR_1_DES=DIVISION)
  
  sr1 <- sr %>% filter(FIRST_TERM_ATTND_CD >= START_TERM & FIRST_TERM_ATTND_CD <= END_TERM & grepl("^U",PRMRY_CRER_CD) & 
                         ENTRY_TYP_SHORT_DES == 'Freshman' & 
                         !grepl('MS',UM_DGR_1_MAJOR_1_DES) & !grepl('MA',UM_DGR_1_MAJOR_1_DES) & !grepl('MPH',UM_DGR_1_MAJOR_1_DES)) %>% 
    drop_na(UM_DGR_1_MAJOR_1_DES) %>% 
    select(c(STDNT_ID,UM_DGR_1_MAJOR_1_DES,STDNT_GNDR_SHORT_DES,STDNT_ETHNC_GRP_SHORT_DES)) %>% mutate(STDNT_ID=as.integer(STDNT_ID))
  
  CLIST <- sc %>% mutate(CRSE_UID=str_c(CRSE_ID_CD,TERM_CD)) %>% 
    filter(TERM_CD >= START_TERM & grepl("^U",PRMRY_CRER_CD) & CATLG_NBR < 500) %>% 
    group_by(CRSE_ID_CD) %>% mutate(N_ENROLL=n(),N_TERM=n_distinct(TERM_CD)) %>% ungroup() %>%
    distinct(CRSE_ID_CD,.keep_all=TRUE) %>% mutate(N_AVG=N_ENROLL/N_TERM) %>% 
    select(c(SBJCT_CD,CATLG_NBR,TERM_CD,TERM_SHORT_DES,CLASS_NBR,CRSE_ID_CD,N_ENROLL,N_TERM,N_AVG,TERMYR))
  
  CLIST <- CLIST %>% filter(N_AVG > 0 & N_TERM >= 0) %>% select(c(CRSE_ID_CD,N_ENROLL,N_TERM,N_AVG))
  subsc <- left_join(CLIST,sc) #%>% filter(TERMYR <= CTERM)
  #subsc2 <- left_join(sr1,subsc)
  
  #STDNT_GNDR_SHORT_DES,STDNT_ETHNC_GRP_SHORT_DES
  
  subsc2 <- left_join(sr1,subsc) %>% drop_na(UM_DGR_1_MAJOR_1_DES) %>% distinct(CRSE_ID_CD,STDNT_ID,.keep_all=TRUE) %>%
    mutate(TOT_STD=n_distinct(STDNT_ID)) %>%                                                   #total students
    group_by(UM_DGR_1_MAJOR_1_DES,STDNT_GNDR_SHORT_DES,STDNT_ETHNC_GRP_SHORT_DES,GRD_PNTS_PER_UNIT_NBR) %>% mutate(N_MAJ=n_distinct(STDNT_ID)) %>%  ungroup() %>%   #for getting fraction of all students in the major
    group_by(UM_DGR_1_MAJOR_1_DES,CRSE_ID_CD,STDNT_GNDR_SHORT_DES,STDNT_ETHNC_GRP_SHORT_DES,GRD_PNTS_PER_UNIT_NBR) %>% mutate(N_CRSE_MAJ=n()) %>%  ungroup() %>%               #for getting the fraction of majors that take this course
    distinct(UM_DGR_1_MAJOR_1_DES,CRSE_ID_CD,STDNT_GNDR_SHORT_DES,STDNT_ETHNC_GRP_SHORT_DES,GRD_PNTS_PER_UNIT_NBR,.keep_all=TRUE) %>% group_by(CRSE_ID_CD) %>% 
    mutate(DENOM=sum(N_MAJ/TOT_STD*N_CRSE_MAJ/N_MAJ)) %>% ungroup() %>% 
    mutate(PROB=N_MAJ/TOT_STD*N_CRSE_MAJ/N_MAJ/DENOM) %>% 
    select(c(UM_DGR_1_MAJOR_1_DES,STDNT_GNDR_SHORT_DES,STDNT_ETHNC_GRP_SHORT_DES,GRD_PNTS_PER_UNIT_NBR,
             CRSE_ID_CD,SBJCT_CD,CATLG_NBR,PROB,DENOM,N_MAJ,N_CRSE_MAJ))
  
  
  return(subsc2)
  
}
