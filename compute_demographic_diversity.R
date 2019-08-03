compute_demographic_diversity <- function()
{
  #sr <- read_tsv("Box Sync/SEISMIC/SEISMIC_Data/student_record.tsv")
  #sc <- read_tsv("Box Sync/SEISMIC/SEISMIC_Data/student_course.tsv")
  
  
}

#binary diversity vector
#1: URM status
#2: GENDER
#3: FIRST_GEN
#4: citizen
#5: low income
compute_student_div_vectors <- function(sr)
{
  sr <- sr %>% mutate(GENDER = case_when(STDNT_GNDR_SHORT_DES == 'Female' ~ 1,
                                         STDNT_GNDR_SHORT_DES == 'Male' ~ 0)) %>% 
               mutate(INTERN = case_when(STDNT_CTZN_STAT_SHORT_DES == 'U.S. Citzn' ~ 0, 
                                         STDNT_CTZN_STAT_SHORT_DES != 'U.S. Citzn' ~ 1)) %>% 
               mutate(LOWINC = case_when(EST_GROSS_FAM_INC_CD <=  50 &
                                         EST_GROSS_FAM_INC_CD >  19 ~ 1)) %>% 
        select(c(STDNT_ID,STDNT_UNDREP_MNRTY_CD,GENDER,INTERN,LOWINC,FIRST_GENERATION))
                              
  return(sr)
  
}

compute_course_diversity <- function(sr_vec,sc)
{
  library(coop)
  
  sc_vec <- left_join(sc,sr_vec,by='STDNT_ID') %>% 
            select(c(STDNT_ID,STDNT_UNDREP_MNRTY_CD,GENDER,INTERN,LOWINC,FIRST_GENERATION))

  STDNT_ID <- as.character(pull(sc_vec[,1],STDNT_ID))
  cos_input <- sc_vec[,c(-1)] #drop the STDNT_ID column b/c we don't need it for the similarity calc.
  
  
  ll <- cosine(t(cos_input))
  
  return(mean(ll,na.rm=TRUE))
}

