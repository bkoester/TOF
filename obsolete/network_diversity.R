#this computes the total diversity of each students' classmates by 
#1) computing the diversity of majors in a course
#2) matching these to each student
#3) computing the mean of the course diversities for each student
#4) return the student course table with the COURSE_DIV (course diversity) and 
#5) CUM_MAJOR_DIV colums added
#sr = student record, requires:
#STDNT_ID
#UM_DGR_1_MAJOR_1_DES
#sc = student course requires:
#TERM_CD
#CLASS_NBR
#
network.diversity <- function(sr,sc)
{
  DEG <- sr %>% group_by(UM_DGR_1_MAJOR_1_DES) %>% select(UM_DGR_1_MAJOR_1_DES) %>% distinct() 
  N   <- length(DEG$UM_DGR_1_MAJOR_1_DES)
  DEG <- add_column(DEG,IND=c(1:N))
  
  sr1  <- left_join(sr,DEG)
  srsub  <- sr1 %>% select(STDNT_ID,UM_DGR_1_MAJOR_1_DES) 
  sc  <- left_join(sc,srsub)
                                
  CLASS_NBR <- sc %>% group_by(CLASS_NBR,UM_DGR_1_MAJOR_1_DES) %>% count()
  CLASS_NBR <- CLASS_NBR %>% group_by(CLASS_NBR) %>% summarize(COURSE_DIV=(sum(n^2)/sum(n)^2)^(1/(1-2)))
  
  sc <- left_join(sc,CLASS_NBR)
  
  #This gives us mean major diversity for each course, and then compute the 
  #mean for each student at the end of their career.
  aa <- sc %>% group_by(STDNT_ID) %>% summarize(MAJOR_DIV = mean(COURSE_DIV)) %>% distinct(STDNT_ID,MAJOR_DIV)
  
  sr <- sr %>% left_join(sr,aa)
  
  return(sr)
  
}

#not used, but keeping around anyway.
compute_course_diversity <- function(df)
{
  
  #tot <- df %>% summarise(tot=sum(n))
  #print(tot)
  #tab <- df %>% select(n)
  #print(df)
  tot <- (df)
  #print(tot)
  tab <- df
  
  q       <- 2
  simp <- (sum(tab^q)/tot^q)^(1/(1-q))
  return(simp)
}