#this take the student course and student record tables
#the student record table is used only to be amended to, and not for any calculations
#the student course table needs:
#1) STDNT_ID
#2) SBCJT_CD
#3) UNITS_ERND_NBR
#4) CATLG_NBR
depth_and_breadth <- function(sr,sc)
{
  
  division <- read_tsv('~/Box\ Sync/PublicDataSets/subject.by.division.tab') %>% select(SUBJECT,DIVISION)
  sc       <- sc %>% left_join(division,by=c("SBJCT_CD"="SUBJECT"))
  
  tempz  <- compute_zemsky_breadth(sc)
  #View(tempz)
  
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
  
  #add curricular stats and zemsky stats
  temp <- add_ca_stats(sc)
  sr  <- left_join(sr,temp)
  sr  <- left_join(sr,tempz)
  
  return(sr)
  
}

add_ca_stats <- function(sc)
{
  #GET THE CURRICULAR ANALYTICS
  ca <- curricular_analytics()
  sc <- sc %>% mutate(COURSE=str_c(SBJCT_CD,CATLG_NBR,sep=" ")) %>% left_join(ca)
  print(names(sc))
  sc$DIVISION[which(sc$DIVISION == 'E')] <- 'S'
  
  
  ##COMPUTE ZEMSKY DEPTH
  cts <- sc %>% group_by(STDNT_ID,DIVISION) %>% summarize(N=n(),N3=sum(DEPTH >= 3),FRAC=N3/N)
  
  sci <- cts %>% filter(DIVISION == 'S') %>% mutate(SCI_TOT=case_when(FRAC>= 0.33 ~ 1,
                                                                      FRAC < 0.33 & FRAC >= 0.167 ~ 0,
                                                                      FRAC < 0.167 ~ -1)) %>% select(-c(DIVISION,N))
  ss  <- cts %>% filter(DIVISION == 'SS' ) %>% mutate(SS_TOT=case_when(FRAC > 0.333 ~ 1,
                                                                       FRAC < 0.33 & FRAC >= 0.167 ~ 0,
                                                                       FRAC < 0.167 ~ -1)) %>% select(-c(DIVISION,N))
  hum <- cts %>% filter(DIVISION == 'H' ) %>% mutate(HUM_TOT=case_when(FRAC>= 0.33 ~ 1,
                                                                       FRAC < 0.33 & FRAC >= 0.167 ~ 0,
                                                                       FRAC < 0.167 ~ -1)) %>% select(-c(DIVISION,N))
  
  sci <- sci %>% left_join(ss,by='STDNT_ID')
  hum <- sci %>% left_join(hum,by='STDNT_ID')
  
  hum <- hum %>% replace_na(list(SCI_TOT=-1,SS_TOT=-1,HUM_TOT=-1))
  hum <- hum %>% mutate(ZEMSKY_DEPTH=SCI_TOT+SS_TOT+HUM_TOT)
  
  #FINISH WITH  SIMPLE MEASURES 
  sc <- sc %>% group_by(STDNT_ID) %>% 
               mutate(maxDEPTH=max(DEPTH,na.rm=TRUE),
                      totDELAY=sum(DELAY,na.rm=TRUE),
                      totBLOCK=sum(BLOCK,na.rm=TRUE),N_CA_MISSING=sum(!is.na(DEPTH)))
  sc <- sc %>% distinct(STDNT_ID,maxDEPTH,totDELAY,totBLOCK,N_CA_MISSING)

  sc <- sc %>% left_join(hum,by='STDNT_ID')
  
  return(sc)
}

compute_zemsky_breadth <- function(sc)
{
  sc$DIVISION[which(sc$DIVISION == 'E')] <- 'S'
  cts <- sc %>% group_by(STDNT_ID,DIVISION) %>% summarize(N=n())
 
  sci <- cts %>% filter(DIVISION == 'S') %>% mutate(SCI_TOT=case_when(N > 3 ~ 1,
                                                                      N == 3 ~ 0,
                                                                      N < 3 ~ -1)) %>% select(-c(DIVISION,N))
  ss  <- cts %>% filter(DIVISION == 'SS' ) %>% mutate(SS_TOT=case_when(N > 3 ~ 1,
                                                                       N == 3 ~ 0,
                                                                       N < 3 ~ -1)) %>% select(-c(DIVISION,N))
  hum <- cts %>% filter(DIVISION == 'H' ) %>% mutate(HUM_TOT=case_when(N > 3 ~ 1,
                                                                       N == 3 ~ 0,
                                                                       N < 3 ~ -1)) %>% select(-c(DIVISION,N))
  sci <- sci %>% left_join(ss,by='STDNT_ID')
  hum <- sci %>% left_join(hum,by='STDNT_ID')
  
  hum <- hum %>% replace_na(list(SCI_TOT=-1,SS_TOT=-1,HUM_TOT=-1))
  hum <- hum %>% mutate(ZEMSKY_BREADTH=SCI_TOT+SS_TOT+HUM_TOT)
  
  return(hum)
  
}
compute_zemsky_depth <- function()
{
  
  
  
  
}