###########################
# File: Simulation.R
# Description: Determines Optimum Roster to Maximize Projected Points and Minimize Risk Based on Simulation
# Date: 5/15/2013
# Author: Isaac Petersen (isaactpetersen@gmail.com)
# Notes:
# -These calculations are from last year (they have not yet been updated for the upcoming season)
###########################

#Specify Maximum Risk
#maxRisk <- 3.8

#Library
library("Rglpk")

#Functions
source(paste(getwd(),"/R Scripts/Functions.R", sep=""))
source(paste(getwd(),"/R Scripts/League Settings.R", sep=""))

#Load data
#load(paste(getwd(),"/Data/AvgCost-2013.RData", sep=""))
load(paste(getwd(),"/Data/BidUpTo-2013.RData", sep=""))
load(paste(getwd(),"/Data/projectedWithActualPoints-2013.RData", sep=""))

#Roster Optimization
optimizeData <- na.omit(projections[,c("name","pos","projections","risk","inflatedCost","sdPts")])
maxCost <- leagueCap - (numTotalPlayers - numTotalStarters)

#Roster Optimization Simulation
iterations <- 100000
solutionList <- matrix(nrow=dim(optimizeData)[1], ncol=iterations)
pb <- txtProgressBar(min = 0, max = iterations, style = 3)
for (i in 1:iterations){
  setTxtProgressBar(pb, i)
  optimizeData$simPts <- mapply(function(x,y) rnorm(n=1, mean=x, sd=y), x=optimizeData$projections, y=optimizeData$sdPts)
  solutionList[,i] <- optimizeTeam(points=optimizeData$simPts, maxRisk=100)$solution
}

solutionSum <- rowSums(solutionList, na.rm=TRUE)
plot(density(na.omit(solutionSum)))
plot(density(na.omit(solutionSum ^ (1/3))))
plot(density(log(solutionSum + 1)))

#best: log(solutionSum + 1)

optimizeData$solutionSum <- solutionSum
optimizeData$percentage <- (optimizeData$solutionSum / iterations) * 100

optimizeData <- optimizeData[order(-optimizeData$solutionSum),c("name","pos","projections","risk","inflatedCost","sdPts","solutionSum","percentage")]

#View Data
optimizeData

#Top QBs
head(optimizeData[which(optimizeData$pos == "QB"),])
head(optimizeData[which(optimizeData$pos == "QB" & optimizeData$risk < 5),])

#Top RBs
head(optimizeData[which(optimizeData$pos == "RB"),])
head(optimizeData[which(optimizeData$pos == "RB" & optimizeData$risk < 5),])

#Top WRs
head(optimizeData[which(optimizeData$pos == "WR"),])
head(optimizeData[which(optimizeData$pos == "WR" & optimizeData$risk < 5),])

#Top TEs
head(optimizeData[which(optimizeData$pos == "TE"),])
head(optimizeData[which(optimizeData$pos == "TE" & optimizeData$risk < 5),])

#View Specific Players
projectedWithActualPts[projectedWithActualPts$name == "Shonn Greene",]
projectedWithActualPts[projectedWithActualPts$name == "Ray Rice",]
projectedWithActualPts[projectedWithActualPts$name == "Jermaine Gresham",]
projectedWithActualPts[projectedWithActualPts$name == "Reggie Wayne",]

#Optimize Solution Sum for Cost
optimizeTeam(points=optimizeData$solutionSum, maxRisk=100)
sum(optimizeData[optimizeData$name %in% optimizeTeam(points=optimizeData$solutionSum, maxRisk=100)$players,"projections"]) #pts: 1593

optimizeTeam(points=optimizeData$solutionSum, maxRisk=5.0)
sum(optimizeData[optimizeData$name %in% optimizeTeam(points=optimizeData$solutionSum, maxRisk=5.0)$players,"projections"]) #pts: 1567

optimizeTeam(points=optimizeData$solutionSum, maxRisk=3.8)
sum(optimizeData[optimizeData$name %in% optimizeTeam(points=optimizeData$solutionSum, maxRisk=3.8)$players,"projections"]) #pts: 1530

#Iterate solutions
projectedPoints <- vector(mode="numeric", length=length(seq(min(optimizeData$risk), max(optimizeData$risk), 0.1)))
riskLevel <- vector(mode="numeric", length=length(seq(min(optimizeData$risk), max(optimizeData$risk), 0.1)))
j <- 1
pb <- txtProgressBar(min = 0, max = max(optimizeData$risk), style = 3)
for (i in seq(0, max(optimizeData$risk), 0.1)){
  setTxtProgressBar(pb, i)
  projectedPoints[j] <- sum(optimizeData[optimizeData$name %in% optimizeTeam(points=log(optimizeData$solutionSum + 1), maxRisk=i)$players,"projections"]) #transform with log or cube root to not give so much weight to highest players
  riskLevel[j] <- i
  j <- j+1
}

riskData <- as.data.frame(cbind(riskLevel,projectedPoints))
riskTable <- riskData[match(unique(riskData$projectedPoints),riskData$projectedPoints),c("riskLevel","projectedPoints")]
riskTable$PtsRiskRatio <- riskTable$projectedPoints / riskTable$riskLevel
riskTable[order(riskTable$projectedPoints),]
plot(riskTable$riskLevel, riskTable$projectedPoints)

optimizeTeam(points=log(optimizeData$solutionSum + 1), maxRisk=3.3)
optimizeTeam(points=log(optimizeData$solutionSum + 1), maxRisk=3.4)
optimizeTeam(points=log(optimizeData$solutionSum + 1), maxRisk=3.5)
optimizeTeam(points=log(optimizeData$solutionSum + 1), maxRisk=3.6)
optimizeTeam(points=log(optimizeData$solutionSum + 1), maxRisk=3.7)
optimizeTeam(points=log(optimizeData$solutionSum + 1), maxRisk=4.0)
optimizeTeam(points=log(optimizeData$solutionSum + 1), maxRisk=4.8) #optimal
optimizeTeam(points=log(optimizeData$solutionSum + 1), maxRisk=4.9)
optimizeTeam(points=log(optimizeData$solutionSum + 1), maxRisk=6.8)

optimizeTeam(points=optimizeData$solutionSum, maxRisk=3.3)
optimizeTeam(points=optimizeData$solutionSum, maxRisk=3.4)
optimizeTeam(points=optimizeData$solutionSum, maxRisk=3.5)
optimizeTeam(points=optimizeData$solutionSum, maxRisk=3.6)
optimizeTeam(points=optimizeData$solutionSum, maxRisk=3.7)
optimizeTeam(points=optimizeData$solutionSum, maxRisk=4.0)
optimizeTeam(points=optimizeData$solutionSum, maxRisk=4.8) #optimal
optimizeTeam(points=optimizeData$solutionSum, maxRisk=4.9)
optimizeTeam(points=optimizeData$solutionSum, maxRisk=6.8)

#Set Optimal Risk
optimalRisk <- 4.8

#Determine Points for Team that Maximizes Log of Solution Sum with Risk < Optimal Risk
optimizeTeam(points=log(optimizeData$solutionSum + 1), maxRisk=optimalRisk)
optimizeData[optimizeData$name %in% optimizeTeam(points=log(optimizeData$solutionSum + 1), maxRisk=optimalRisk)$players, c("name","projections")]
sum(optimizeData[optimizeData$name %in% optimizeTeam(points=log(optimizeData$solutionSum + 1), maxRisk=optimalRisk)$players, "projections"]) #projected pts: 1500
projectedWithActualPts[projectedWithActualPts$name %in% optimizeTeam(points=log(optimizeData$solutionSum + 1), maxRisk=optimalRisk)$players, c("name","projections","actualPts")]
sum(projectedWithActualPts[projectedWithActualPts$name %in% optimizeTeam(points=log(optimizeData$solutionSum + 1), maxRisk=optimalRisk)$players, "actualPts"]) #actual points from last year: 1339

#Maximum Possible with Same Risk
optimizeTeam(maxRisk=optimalRisk) #1528