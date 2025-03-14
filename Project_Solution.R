# Solution.R
# This is the Solution file for Homework 4 of course:
# Bayesian Computing for Data Science (DATS 6311, Fall 2021)
# Data Science @ George Washington University
# Author: Yuxiao Huang

# Reference:
# Some of the code is from the book by Professor John K. Kruschke
# Please find the reference to and website of the book below:
# Kruschke, J. K. (2014). Doing Bayesian Data Analysis: A Tutorial with R, JAGS, and Stan. 2nd Edition. Academic Press / Elsevier
# https://sites.google.com/site/doingbayesiandataanalysis/

# Students should complete the following function in Solution.R:
# genMCMC: generates the MCMC chain

source("DBDA2E-utilities.R")

genMCMC = function( data , numSavedSteps=50000 , saveName=NULL ) { 
  require(rjags)
  #-----------------------------------------------------------------------------
  # THE DATA.
  # N.B.: This function expects the data to be a data frame, 
  # with one component named y being a vector of integer 0,1 values,
  # and one component named s being a factor of subject identifiers.
  
  print('Here1')
  #Company Types
  # yA = data$Company_Type_NGO
  # yB = data$Company_Type_Other
  # yC = data$Company_Type_Public_Sector
  # yD = data$Company_Type_Pvt_Ltd
  # yE = data$Company_Type_Startup
  
  #Company Size
  # yA = data$Company_Size_Large
  # yB = data$Company_Size_Medium
  # yC = data$Company_Size_Small
  
  #Experience
  # yA = data$Years_Experience_between_five_and_ten
  # yB = data$Years_Experience_less_than_five
  # yC = data$Years_Experience_more_than_ten
  
  #Most recent job
  # yA = data$New_Job_zero
  # yB = data$New_Job_one
  # yC = data$New_Job_two
  # yD = data$New_Job_three
  # yE = data$New_Job_four
  # yF = data$New_Job_five
  
  
  #Highest Education
  # yA = data$Education_Highest_Bachelors
  # yB = data$Education_Highest_Masters
  # yC = data$Education_Highest_Phd
  # yD = data$Education_Highest_PublicEducation
  
  #Highest Education
  yA = data$Education_Total_Bachelors
  yB = data$Education_Total_Masters
  yC = data$Education_Total_Phd
  yD = data$Education_Total_PublicEducation
  
  print('Here2')
  #3 groups
  # y = c(yA, yB, yC)
  # s = c(rep(1, length(yA)), rep(2, length(yB)), rep(3, length(yC)))

  #4 groups
  y = c(yA, yB, yC)
  s = c(rep(1, length(yA)), rep(2, length(yB)), rep(3, length(yC)), 
        rep(4, length(yD)))
  
  #5 groups
  # y = c(yA, yB, yC, yD, yE)
  # s = c(rep(1, length(yA)), rep(2, length(yB)), rep(3, length(yC)),
  #       rep(4, length(yD)), rep(5, length(yE)))
  
  #6 groups
  # y = c(yA, yB, yC, yD, yE)
  # s = c(rep(1, length(yA)), rep(2, length(yB)), rep(3, length(yC)),
  #       rep(4, length(yD)), rep(5, length(yE)), rep(6, length(yF)) )

  print('Here1')
  # Do some checking that data make sense:
  if ( any( y!=0 & y!=1) ) { stop("All y values must be 0 or 1.") }
  
  Ntotal = length(y)
  Nsubj = length(unique(s))
  
  print('Here3')
  # Specify the data in a list, for later shipment to JAGS:
  dataList = list(
    y = y,
    s = s,
    Ntotal = Ntotal
  )
  print('Here1')
  #-----------------------------------------------------------------------------
  # THE MODEL.
  modelString3 = "
  model {
  for ( i in 1:Ntotal ) {
  y[i] ~ dbern( theta[s[i]] )
  }
  theta[1] ~ dbeta(1, 1)
  theta[2] ~ dbeta(1, 1)
  theta[3] ~ dbeta(1, 1)
  }
  " # close quote for modelString
  modelString4 = "
  model {
  for ( i in 1:Ntotal ) {
  y[i] ~ dbern( theta[s[i]] )
  }
  theta[1] ~ dbeta(1, 1)
  theta[2] ~ dbeta(1, 1)
  theta[3] ~ dbeta(1, 1)
  theta[4] ~ dbeta(1, 1)
  }
  " # close quote for modelString
  modelString5 = "
  model {
  for ( i in 1:Ntotal ) {
  y[i] ~ dbern( theta[s[i]] )
  }
  theta[1] ~ dbeta(1, 1)
  theta[2] ~ dbeta(1, 1)
  theta[3] ~ dbeta(1, 1)
  theta[4] ~ dbeta(1, 1)
  theta[5] ~ dbeta(1, 1)
  }
  " # close quote for modelString
  
  modelString6 = "
  model {
  for ( i in 1:Ntotal ) {
  y[i] ~ dbern( theta[s[i]] )
  }
  theta[1] ~ dbeta(1, 1)
  theta[2] ~ dbeta(1, 1)
  theta[3] ~ dbeta(1, 1)
  theta[4] ~ dbeta(1, 1)
  theta[5] ~ dbeta(1, 1)
  theta[6] ~ dbeta(1, 1)
  }
  " # close quote for modelString
  
  
  #modelString# --> # indicates how many thetas
  writeLines( modelString4, con="TEMPmodel.txt" )
  #-----------------------------------------------------------------------------
  # INTIALIZE THE CHAINS.
  # Initial values of MCMC chains based on data:
  # Option 1: Use single initial value for all chains:
  #  thetaInit = rep(0,Nsubj)
  #  for ( sIdx in 1:Nsubj ) { # for each subject
  #    includeRows = ( s == sIdx ) # identify rows of this subject
  #    yThisSubj = y[includeRows]  # extract data of this subject
  #    thetaInit[sIdx] = sum(yThisSubj)/length(yThisSubj) # proportion
  #  }
  #  initsList = list( theta=thetaInit )
  # Option 2: Use function that generates random values near MLE:
  initsList = function() {
    thetaInit = rep(0,Nsubj)
    for ( sIdx in 1:Nsubj ) { # for each subject
      includeRows = ( s == sIdx ) # identify rows of this subject
      yThisSubj = y[includeRows]  # extract data of this subject
      resampledY = sample( yThisSubj , replace=TRUE ) # resample
      thetaInit[sIdx] = sum(resampledY)/length(resampledY) 
    }
    thetaInit = 0.001+0.998*thetaInit # keep away from 0,1
    return( list( theta=thetaInit ) )
  }
  #-----------------------------------------------------------------------------
  # RUN THE CHAINS
  parameters = c( "theta")     # The parameters to be monitored
  adaptSteps = 500             # Number of steps to adapt the samplers
  burnInSteps = 500            # Number of steps to burn-in the chains
  nChains = 4                  # nChains should be 2 or more for diagnostics 
  thinSteps = 1
  nIter = ceiling( ( numSavedSteps * thinSteps ) / nChains )
  # Create, initialize, and adapt the model:
  jagsModel = jags.model( "TEMPmodel.txt" , data=dataList , inits=initsList , 
                          n.chains=nChains , n.adapt=adaptSteps )
  # Burn-in:
  cat( "Burning in the MCMC chain...\n" )
  update( jagsModel , n.iter=burnInSteps )
  # The saved MCMC chain:
  cat( "Sampling final MCMC chain...\n" )
  codaSamples = coda.samples( jagsModel , variable.names=parameters , 
                              n.iter=nIter , thin=thinSteps )
  # resulting codaSamples object has these indices: 
  #   codaSamples[[ chainIdx ]][ stepIdx , paramIdx ]
  if ( !is.null(saveName) ) {
    save( codaSamples , file=paste(saveName,"Mcmc.Rdata",sep="") )
  }
  return( codaSamples )
} # end function

#===============================================================================

smryMCMC = function(  codaSamples , compVal=0.5 , rope=NULL , 
                      compValDiff=0.0 , ropeDiff=NULL , saveName=NULL ) {
  mcmcMat = as.matrix(codaSamples,chains=TRUE)
  Ntheta = length(grep("theta",colnames(mcmcMat)))
  summaryInfo = NULL
  rowIdx = 0
  for ( tIdx in 1:Ntheta ) {
    parName = paste0("theta[",tIdx,"]")
    summaryInfo = rbind( summaryInfo , 
                         summarizePost( mcmcMat[,parName] , compVal=compVal , ROPE=rope ) )
    rowIdx = rowIdx+1
    rownames(summaryInfo)[rowIdx] = parName
  }
  for ( t1Idx in 1:(Ntheta-1) ) {
    for ( t2Idx in (t1Idx+1):Ntheta ) {
      parName1 = paste0("theta[",t1Idx,"]")
      parName2 = paste0("theta[",t2Idx,"]")
      summaryInfo = rbind( summaryInfo , 
                           summarizePost( mcmcMat[,parName1]-mcmcMat[,parName2] ,
                                          compVal=compValDiff , ROPE=ropeDiff ) )
      rowIdx = rowIdx+1
      rownames(summaryInfo)[rowIdx] = paste0(parName1,"-",parName2)
    }
  }
  if ( !is.null(saveName) ) {
    write.csv( summaryInfo , file=paste(saveName,"SummaryInfo.csv",sep="") )
  }
  show( summaryInfo )
  return( summaryInfo )
}

#===============================================================================

plotMCMC = function( codaSamples , data , compVal=0.5 , rope=NULL , 
                     compValDiff=0.0 , ropeDiff=NULL , 
                     saveName=NULL , saveType="jpg" ) {
  #-----------------------------------------------------------------------------
  # N.B.: This function expects the data to be a data frame, 
  # with one component named y being a vector of integer 0,1 values,
  # and one component named s being a factor of subject identifiers.
  y = data$y
  s = as.numeric(data$s) # converts character to consecutive integer levels
  # Now plot the posterior:
  mcmcMat = as.matrix(codaSamples,chains=TRUE)
  chainLength = NROW( mcmcMat )
  Ntheta = length(grep("theta",colnames(mcmcMat)))
  openGraph(width=2.5*Ntheta,height=2.0*Ntheta)
  par( mfrow=c(Ntheta,Ntheta) )
  for ( t1Idx in 1:(Ntheta) ) {
    for ( t2Idx in (1):Ntheta ) {
      parName1 = paste0("theta[",t1Idx,"]")
      parName2 = paste0("theta[",t2Idx,"]")
      if ( t1Idx > t2Idx) {  
        # plot.new() # empty plot, advance to next
        par( mar=c(3.5,3.5,1,1) , mgp=c(2.0,0.7,0) )
        nToPlot = 700
        ptIdx = round(seq(1,chainLength,length=nToPlot))
        plot ( mcmcMat[ptIdx,parName2] , mcmcMat[ptIdx,parName1] , cex.lab=1.75 ,
               xlab=parName2 , ylab=parName1 , col="skyblue" )
      } else if ( t1Idx == t2Idx ) {
        par( mar=c(3.5,1,1,1) , mgp=c(2.0,0.7,0) )
        postInfo = plotPost( mcmcMat[,parName1] , cex.lab = 1.75 , 
                             compVal=compVal , ROPE=rope , cex.main=1.5 ,
                             xlab=parName1 , main="" )
        includeRows = ( s == t1Idx ) # identify rows of this subject in data
        dataPropor = sum(y[includeRows])/sum(includeRows) 
        points( dataPropor , 0 , pch="+" , col="red" , cex=3 )
      } else if ( t1Idx < t2Idx ) {
        par( mar=c(3.5,1,1,1) , mgp=c(2.0,0.7,0) )
        postInfo = plotPost(mcmcMat[,parName1]-mcmcMat[,parName2] , cex.lab = 1.75 , 
                            compVal=compValDiff , ROPE=ropeDiff , cex.main=1.5 ,
                            xlab=paste0(parName1,"-",parName2) , main="" )
        includeRows1 = ( s == t1Idx ) # identify rows of this subject in data
        dataPropor1 = sum(y[includeRows1])/sum(includeRows1) 
        includeRows2 = ( s == t2Idx ) # identify rows of this subject in data
        dataPropor2 = sum(y[includeRows2])/sum(includeRows2) 
        points( dataPropor1-dataPropor2 , 0 , pch="+" , col="red" , cex=3 )
      }
    }
  }
  #-----------------------------------------------------------------------------  
  if ( !is.null(saveName) ) {
    saveGraph( file=paste(saveName,"Post",sep=""), type=saveType)
  }
}

#===============================================================================
