#this reads in the formatted prerequisite list,
#computes Heileman network statistics for each course, including depth.
#Inspired by, taken from Heileman et al (2018): https://arxiv.org/abs/1811.09676
curricular_analytics <- function()
{
  library(readxl)
  library(igraph)
  pre <- read_csv('~bkoester/Google Drive/code/REBUILD/UMILA/prerequisites/prereq_list_enforced.csv')
  #prexl <- read_xls('~bkoester/Google Drive/code/REBUILD/UMILA/prerequisites/M_CA_ENFORCED_PREREQUISITES.xlsx')
  
  jj1 <- compute_all_delay_factors(pre)
  jj2 <- compute_all_blocking_factors(pre)
  jj3 <- compute_prereq_depth(pre)
  
  out <- left_join(jj1,jj2)
  out <- left_join(out,jj3)
  
  names(out) <- c('COURSE','DELAY','BLOCK','PATH','DEPTH')
  out <- out %>% select('COURSE','DELAY','BLOCK','DEPTH','PATH')
                  
  
  return(out)#list(jj1,jj2,jj3))
  
}

#compute prequisite depth.
compute_prereq_depth <- function(pre)
{
  #note all the paths for the purposes of delay factors
  adjmtx <- vectorize_courses(pre)                              #creates adjacency matrix
  net   <- graph_from_adjacency_matrix(adjmtx,mode='directed')  #converts adjacency mtx to igraph object
  
  ncrse <- dim(adjmtx)[1]
  DEPTH <- mat.or.vec(ncrse,1)
  pname <- vector(mode="character",length=ncrse)
  cname <- pname
  path  <- pname
  
  for (i in 1:dim(adjmtx)[1])
  {
    j <- ego(net,order=20,nodes=i,mode='in') #find all paths coming into this course
    
    path[i]   <- paste(names(j[[1]]),collapse='-')
    cname[i]  <- names(j[[1]][1])
    DEPTH[i]  <- length(j[[1]])              #count the number of courses on the longest path 
  }
  
  out <- data.frame(path,cname,DEPTH)
  return(out)
  
}

#compute delay factor for each course
compute_all_delay_factors <- function(pre)
{
  adjmtx <- vectorize_courses(pre)
  net   <- graph_from_adjacency_matrix(adjmtx,mode='directed')
  
  ncrse <- dim(adjmtx)[1]
  DELAY <- mat.or.vec(ncrse,1)
  pname <- vector(mode="character",length=ncrse)
  cname <- rownames(adjmtx) #pname
  
  for (i in 1:ncrse)
  {
     DELAY[i] <- diameter(make_ego_graph(net,order=10,nodes=V(net)[i])[[1]])
  }
  return(data.frame(cname,DELAY))
}

#compute course blocking factor.
compute_all_blocking_factors <- function(pre)
{
  #note all the paths for the purposes of delay factors
  adjmtx <- vectorize_courses(pre)
  net   <- graph_from_adjacency_matrix(adjmtx,mode='directed')
  
  ncrse <- dim(adjmtx)[1]
  BLOCK <- mat.or.vec(ncrse,1)
  pname <- vector(mode="character",length=ncrse)
  cname <- pname
  
  for (i in 1:dim(adjmtx)[1])
  {
    temp <- subcomponent(net,i,mode='out')
    cname[i]    <- names(temp[[1]])
    BLOCK[i]  <- length(temp)
  }
  
  out <- data.frame(cname,BLOCK)
  return(out)

}

#compute prerequisite pathways
compute_all_pre_pathways <- function(pre,RETURN_ALL=FALSE)
{
  adjmtx <- vectorize_courses(pre)
  
  #note all the paths for the purposes of delay factors
  for (i in 1:dim(adjmtx)[1])
  {
    temp <- build_course_graph(adjmtx,i,RETURN_ALL=RETURN_ALL)
    print(i)
    if (i == 1){t <- temp}
    if (i > 1) {t <- rbind(t,temp)}
  }
  
  return(t)
}


#compute the prerequisite adjancency matrix
#this matrix is centrol to the 
vectorize_courses <- function(pre)
{
  pre   <- as.data.frame(pre)
  prect <- pre[,-c(76,77)]
  
  for (i in 1:dim(prect)[1])
  {
    temp <- as.character(c(prect[i,]))
    if (i == 1){t <- temp}
    if (i > 1){t <- c(t,temp)}
  }
 
  t      <- t[which(!is.na(t))]
  t      <- unique(t)
  ttemp  <- pre$crse_temp
  
  tind   <- c(1:length(t))
  ncrse  <- length(t)
  adjmtx <- mat.or.vec(ncrse,ncrse)
 
  #first fill in a matrix
  for (i in 1:ncrse)
  {
    #print(i)
     e <- which(pre$crse_temp == t[i])
     j <- 2
     
     if (t[i] %in% ttemp)
     {
      while (!is.na(pre[e,j]) & j < 76)
      {
        f <- which(t == pre[e,j])
        adjmtx[i,f] <- 1
        j <- j + 1
     }
  }
  }
  
  rownames(adjmtx) <- t
  colnames(adjmtx) <- t
  
  
  return(adjmtx)
  
}


build_course_graph <- function(adjmtx,nodenum,RETURN_ALL=FALSE)
{
  library(igraph)

  net   <- graph_from_adjacency_matrix(adjmtx,mode='directed')
  paths <- shortest_paths(net,nodenum)
  ncrse <- length(paths$vpath)
  plength <- mat.or.vec(ncrse,1)
  pname <- vector(mode="character",length=ncrse)
  cname <- pname
  cname[] <- names(V(net))[nodenum]
 
  
  for (i in 1:length(paths$vpath))
  {
    print(paths$vpath[[i]])
    plength[i] <- length(paths$vpath[[i]])
   
    if (plength[i] > 0){pname[i]   <- paste(names(paths$vpath[[i]]),collapse="-")}
    
  }
  
  out <- data.frame(cname,pname,plength)
  #out <- out[sort(out)
  if (RETURN_ALL == FALSE){out <- out[order(-out$plength),]; out <- out[1,]}
  
  return(out)
}

find_longest_course_path <- function(pre,course='MATH 115')
{
  h <- which(pre$crse_temp == course)
  nsub <- pre$subsqnt_cnt[h]

}

#this is seldom-used, originally here for parsing the raw prequisite lists more carefully.
reduce_raw_prereq_list <- function(prexl)
{
  ncrse <- dim(prexl)[1]
  PRE_CRSE_NAME <- str_c(prexl$Subject,prexl$Catalog,sep=" ")
  
  for (i in 1:ncrse)
  {
    
    temp <- analyze_prereq_string(prexl$`Long Descr`[i])
    
    npre <- dim(temp)[1]
    
    if (temp != 0)
    {
      if (temp$ampct[1] > 0 | temp$andct[1] > 0){WT <- npre/(npre+temp$orct[1])}
      if (temp$ampct[1] == 0 & temp$andct[1] == 0){WT <- 1./npre}
      temp$WT <- WT
      temp$PRE_CRSE_NAME <- PRE_CRSE_NAME[i]
      if (i == 1){t <- temp}
      if (i > 1){t <- rbind(t,temp)}
    }
  }
  
  e <- which(t$PRE_CRSE_NAME == t$CRSE_NAME)
  print(str_c("found and removed ",(length(e))," self-pair mistakes"))
  t <- t[which(t$PRE_CRSE_NAME != t$CRSE_NAME & t$CRSE_NAME != 'NoCred'),]
  
  return(t)
  
}

vectorize_new_pre <- function(prexl)
{
  clist  <- c(as.character(prexl$CRSE_NAME),as.character(prexl$PRE_CRSE_NAME))
  t  <- unique(clist)
  ttemp  <- prexl$PRE_CRSE_NAME
  
  tind   <- c(1:length(t))
  ncrse  <- length(t)
  adjmtx <- mat.or.vec(ncrse,ncrse)
  
  #first fill in a matrix
  for (i in 1:ncrse)
  {
    #print(i)
    #e  <- which(prexl$PRE_CRSE_NAME == t[i])
    #ne <- length(e) 
    
    #    adjmtx[i,f] <- 1
    #    j <- j + 1
    #  }
    #}
  }
  
  rownames(adjmtx) <- t
  colnames(adjmtx) <- t
  
  
  return(adjmtx)
  
}

analyze_prereq_string <- function(descr)
{
  #clean out garbage
  descr <- str_replace(descr,"or better","blank")
  
  #find all three digit strings
  catpos <- str_locate_all(descr,pattern="\\d{3}")
  ncat <- dim(catpos[[1]])[1]
  if (ncat == 0){return(0)}
  
  #find all subject codes
  subjpos <- str_locate_all(descr,pattern="[[:upper:]]{2,}")
  nsub <- dim(subjpos[[1]])[1]
  if (nsub == 0){return(0)}
  
  #find all nons
  noct   <- str_count(descr,pattern="(N|n)o")
  nopos <- 1000
  if (noct > 0){nopos   <- as.numeric(str_locate_all(descr,pattern="(N|n)o")[[1]][1,1])}

  #find all ors
  orct   <- str_count(descr,pattern="or")
  #orpos <- 1000
  #if (orct > 0){nor   <- as.numeric(str_locate_all(descr,pattern="or")[[1]][1,1])}
  
  #find all ands
  andct   <- str_count(descr,pattern="and")
  #orpos <- 1000
  #if (orct > 0){nand   <- as.numeric(str_locate_all(descr,pattern="and")[[1]][1,1])}
  
  ampct <- str_count(descr,pattern="&")
  
  aa <- str_sub(descr,dd[[1]][i,1]-3,dd[[1]][i,2]-3)
  
  CRSE_NAME <- mat.or.vec(ncat,1)
  
  for (i in 1:ncat)
  {
    begcat <- as.numeric(catpos[[1]][i,1])
    CAT    <- str_sub(descr,catpos[[1]][i,1],catpos[[1]][i,2])
    
    for (j in 1:nsub)
    {
      SUB    <- str_sub(descr,subjpos[[1]][j,1],subjpos[[1]][j,2])
      endsub <- as.numeric(subjpos[[1]][j,2])
      if (endsub < begcat){CRSE_NAME[i] = str_c(SUB,CAT,sep=" ")}
      if (endsub > nopos & begcat > nopos){CRSE_NAME[i] = 'NoCred'}
    }
  }
  
  nocred <- length(which(CRSE_NAME == 'NoCred'))
  if (nocred == length(CRSE_NAME)){return(0)}
  
  return(data.frame(CRSE_NAME,orct,andct,ampct))
}
