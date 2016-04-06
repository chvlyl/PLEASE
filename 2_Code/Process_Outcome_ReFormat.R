suppressMessages(require(reshape))

DISACT.raw = read.table('PLEASE-DISACT-modified.txt',sep='\t',header=T,na.strings = "NULL",stringsAsFactors=FALSE,colClasses = c( "character" ))
## Pid,Vnum,Vdate,pcdai
DISACT = DISACT.raw[,c('Pid','Vnum','Vdate','pcdai','AbdominalPain','Bleeding','StoolConsistency','Frequency','NocturnalBMs','Activity')]
rownames(DISACT) = paste(DISACT.raw[,'Pid'],'-0',as.numeric(DISACT.raw[,'Vnum'])+1,sep='')

## The orignal PCDAI has some errors in it. Need to corret it.
## ID	VNUM	# in DISACT (Dis23)	My calc	Reason
## 5002	0	47.5	52.5	Miscalculation; should be 52.5
## 5002	3	NULL	35	Should be 35. The total wasn’t written in on the CRF.  The blood work scores are missing so this is not a complete score. I’d  like to check the source doc or the med chart to verify.
## 5006	3	0	5	Miscalculation – this should be 5 on the CRF.
## 5020	0	20	11 (but I think dis 15 was mistyped as 1 instead of 10)	Dis 15 on the CRF has a score of 10, not 1.  Dis16 and Dis20 both have a score of 5, for a total score of 20.
## 5037	0	62.5	67.5	Miscalculation – should be 67.5
## 7002	3	15	10	Miscalculation – should be 10.
DISACT["5002-01","pcdai"] <- "52.5"
DISACT["5002-04","pcdai"] <- "35"
DISACT["5006-04","pcdai"] <- "5"
DISACT["5020-01","pcdai"] <- "11"
DISACT["5037-01","pcdai"] <- "67.5"
DISACT["7002-04","pcdai"] <- "10"


FCP.raw = read.table('PLEASE-FCP-modified.txt',sep='\t',header=T,na.strings = "NULL",stringsAsFactors=FALSE,colClasses = c( "character" ))
## Pid,Vnum,Vdate,CollectDate,BristolScore,CalproteinConcentration
FCP = FCP.raw[,c('Pid','Vnum','Vdate','CollectDate','BristolScore','CalproteinConcentration')]
rownames(FCP) = paste(FCP.raw[,'Pid'],'-0',as.numeric(FCP.raw[,'Vnum'])+1,sep='')

TSTOP.raw = read.table('PLEASE-TSTOP-modified.txt',sep='\t',header=T,na.strings = "NULL",stringsAsFactors=FALSE,colClasses = c( "character" ))
## Pid,Vnum,Vdate,StopDate,StopReason
TSTOP = TSTOP.raw[,c('Pid','Vnum','Vdate','StopDate','StopReason')]
rownames(TSTOP) = paste(TSTOP.raw[,'Pid'],'-0',as.numeric(TSTOP.raw[,'Vnum'])+1,sep='')

INITIATE.raw = read.table('PLEASE-INITIATE-modified.txt',sep='\t',header=T,na.strings = "NULL",stringsAsFactors=FALSE,colClasses = c( "character" ))
## Pid,Vnum,Vdate,EnteralTherapy,EnteralTherapyDate,antiTNF,antiTNFDate
INITIATE = INITIATE.raw[,c('Pid','Vnum','Vdate','EnteralTherapy','EnteralTherapyDate','antiTNF','antiTNFDate')]
rownames(INITIATE) = paste(INITIATE.raw[,'Pid'],'-0',as.numeric(INITIATE.raw[,'Vnum'])+1,sep='')

## Load plate information
#Plate	Sample
#Plate0	5001-01
plate.info = '/media/THING2/eric/0_PLEASE_Fastq/Plate_Source_for_Samples.txt'
plate.raw = read.table(plate.info, sep='\t',header=T,stringsAsFactors=FALSE)

#################################################################################################
#################################################################################################
Samples = sort(union(union(INITIATE[,'Pid'], DISACT[,'Pid']),FCP[,'Pid']))
ColNames = c('Plate','StopDate','TreatmentStartDate','DiffStopStart','Treatment',
		'BristolScore_1','BristolScore_2','BristolScore_3','BristolScore_4',
		'StopReason','PUCAI_1','PUCAI_2','PUCAI_3','PUCAI_4',
    'PCDAI_1','PCDAI_4','FCP_1','FCP_2','FCP_3','FCP_4',
		'PUCAIResponse','PCDAIRemission','PCDAIResponse','FCP50','FCPResponse','FCPGreaterRedution','MergedResponse'
		)

MergedTable = data.frame(matrix(NA, nrow = length(Samples), ncol = length(ColNames)),stringsAsFactors=F)
colnames(MergedTable) = ColNames
rownames(MergedTable) = Samples

### Plate information
plate.SampleTimeMatrix = colsplit(plate.raw[,2], split = "-", names = c('Subject', 'Time'))
plate = unique(cbind(Plate=plate.raw[,1],Sample=plate.SampleTimeMatrix[,1]))
plate.sample = plate[,2]
rownames(plate) = plate.sample
MergedTable[intersect(Samples, plate.sample),'Plate'] = plate[intersect(Samples, plate.sample),1]

### StopData and StopReason
MergedTable[TSTOP[,'Pid'],c('StopDate','StopReason')] = TSTOP[,c('StopDate','StopReason')]

### Treatment
Treat     = rep(NA,nrow(INITIATE))
TreatTime = rep(NA,nrow(INITIATE))
for (i in 1:nrow(INITIATE)){
	Treat[i] = ifelse(INITIATE[i,'EnteralTherapy'] == '1','Diet','antiTNF')
	TreatTime[i] = ifelse(INITIATE[i,'EnteralTherapy'] == '1',INITIATE[i,'EnteralTherapyDate'],INITIATE[i,'antiTNFDate'])
}
MergedTable[INITIATE[,'Pid'],c('Treatment','TreatmentStartDate')] = cbind(Treatment=Treat,TreatmentStartDate=TreatTime)

### PCDAI
MergedTable[ DISACT[DISACT[,'Vnum'] == 0,c('Pid')],c('PCDAI_1')] = DISACT[DISACT[,'Vnum'] == 0,c('pcdai')]
MergedTable[ DISACT[DISACT[,'Vnum'] == 3,c('Pid')],c('PCDAI_4')] = DISACT[DISACT[,'Vnum'] == 3,c('pcdai')]

### PUCAI
##Question	Variable name	Score
##Abdominal pain	Dis3	0=0, 1=5, 2=10
##Bleeding	Dis4	0=0, 1=10, 2=20, 3=30
##Stool consistency	Dis5	0=0, 1=5, 2=10
##Frequency	Dis6	0=0, 1=5, 2=10, 3=15
##Nocturnal BMs	Dis7	0=0, 1=10
##Activity limitations	Dis8	0=0, 1=5, 2=10
##PUCAI	Sum Dis3 to Dis8
PUCAI.mat = data.matrix(DISACT[,c('AbdominalPain','Bleeding','StoolConsistency','Frequency','NocturnalBMs','Activity')])
PUCAI.weight = PUCAI.mat * 0
PUCAI.weight[,'AbdominalPain'] = 5
PUCAI.weight[,'Bleeding'] = 10
PUCAI.weight[,'StoolConsistency'] = 5
PUCAI.weight[,'Frequency'] = 5
PUCAI.weight[,'NocturnalBMs'] = 10
PUCAI.weight[,'Activity'] = 5
PUCAI.mat.weight = PUCAI.mat * PUCAI.weight
MergedTable[ DISACT[DISACT[,'Vnum'] == 0,'Pid'],'PUCAI_1'] = rowSums(PUCAI.mat.weight[DISACT[,'Vnum'] == 0,])
MergedTable[ DISACT[DISACT[,'Vnum'] == 1,'Pid'],'PUCAI_2'] = rowSums(PUCAI.mat.weight[DISACT[,'Vnum'] == 1,])
MergedTable[ DISACT[DISACT[,'Vnum'] == 2,'Pid'],'PUCAI_3'] = rowSums(PUCAI.mat.weight[DISACT[,'Vnum'] == 2,])
MergedTable[ DISACT[DISACT[,'Vnum'] == 3,'Pid'],'PUCAI_4'] = rowSums(PUCAI.mat.weight[DISACT[,'Vnum'] == 3,])

### FCP
MergedTable[ FCP[FCP[,'Vnum'] == 0,c('Pid')],c('FCP_1')] = FCP[FCP[,'Vnum'] == 0,c('CalproteinConcentration')]
MergedTable[ FCP[FCP[,'Vnum'] == 1,c('Pid')],c('FCP_2')] = FCP[FCP[,'Vnum'] == 1,c('CalproteinConcentration')]
MergedTable[ FCP[FCP[,'Vnum'] == 2,c('Pid')],c('FCP_3')] = FCP[FCP[,'Vnum'] == 2,c('CalproteinConcentration')]
MergedTable[ FCP[FCP[,'Vnum'] == 3,c('Pid')],c('FCP_4')] = FCP[FCP[,'Vnum'] == 3,c('CalproteinConcentration')]
#print(length(MergedTable[ FCP[FCP[,'Vnum'] == 0,c('Pid')],c('FCP_1')]))
#print(length(FCP[FCP[,'Vnum'] == 0,c('CalproteinConcentration')]))
#print(length(MergedTable[ FCP[FCP[,'Vnum'] == 1,c('Pid')],c('FCP_2')]))
#print(length(FCP[FCP[,'Vnum'] == 1,c('CalproteinConcentration')]))
#print(length(MergedTable[ FCP[FCP[,'Vnum'] == 2,c('Pid')],c('FCP_3')]))
#print(length(FCP[FCP[,'Vnum'] == 2,c('CalproteinConcentration')]))
#print(length(MergedTable[ FCP[FCP[,'Vnum'] == 3,c('Pid')],c('FCP_4')]))
#print(length(FCP[FCP[,'Vnum'] == 3,c('CalproteinConcentration')]))


### BristolScore
MergedTable[ FCP[FCP[,'Vnum'] == 0,c('Pid')],c('BristolScore_1')] = FCP[FCP[,'Vnum'] == 0,c('BristolScore')]
MergedTable[ FCP[FCP[,'Vnum'] == 1,c('Pid')],c('BristolScore_2')] = FCP[FCP[,'Vnum'] == 1,c('BristolScore')]
MergedTable[ FCP[FCP[,'Vnum'] == 2,c('Pid')],c('BristolScore_3')] = FCP[FCP[,'Vnum'] == 2,c('BristolScore')]
MergedTable[ FCP[FCP[,'Vnum'] == 3,c('Pid')],c('BristolScore_4')] = FCP[FCP[,'Vnum'] == 3,c('BristolScore')]


################################################################################################################
#### Define the response variables

### Difference between start and stop time
MergedTable[,c('DiffStopStart')] = as.Date(MergedTable[,c('StopDate')], format="%d-%b-%y") - 
				as.Date(MergedTable[,c('TreatmentStartDate')], "%d-%b-%y")

### PUCAI response
### for patients in whom we have PUCAI but not PCDAI results, 
### we will consider those with a reduction of 20 points to be responders. 
MergedTable[ ,c('PUCAIResponse')] = ifelse((as.numeric(MergedTable[ ,c('PUCAI_1')]) - as.numeric(MergedTable[ ,c('PUCAI_4')])) >= 20, 1,0)

### PCDAI remission
MergedTable[ ,c('PCDAIRemission')] = ifelse(as.numeric(MergedTable[ ,c('PCDAI_4')]) <= 10, 1,0)

### PCDAI response
MergedTable[ ,c('PCDAIResponse')] = ifelse( (as.numeric(MergedTable[ ,c('PCDAI_4')]) <= 10) | (as.numeric(MergedTable[ ,c('PCDAI_1')]) - as.numeric(MergedTable[ ,c('PCDAI_4')])) >= 15, 1,0)

### FCP50: time point 4
for (i in 1:nrow(MergedTable)){
	MergedTable[i,c('FCP50')] = ifelse( (as.numeric(MergedTable[i,c('FCP_4')]) <= 50), 1,0)
	MergedTable[i,c('FCP50')] = ifelse( (as.numeric(MergedTable[i,c('FCP_1')]) <= 50), NA, MergedTable[i,c('FCP50')])
}


### FCP response
for (i in 1:nrow(MergedTable)){
	MergedTable[i,c('FCPResponse')] = ifelse( (as.numeric(MergedTable[i,c('FCP_4')]) <= 250), 1,0)
	MergedTable[i,c('FCPResponse')] = ifelse( (as.numeric(MergedTable[i,c('FCP_1')]) <= 250), NA, MergedTable[i,c('FCPResponse')])
}
### FCP reduction > 50%
for (i in 1:nrow(MergedTable)){
	MergedTable[i,c('FCPGreaterRedution')] = ifelse( (as.numeric(MergedTable[i,c('FCP_1')]) - as.numeric(MergedTable[i,c('FCP_4')]) ) / as.numeric(MergedTable[i,c('FCP_1')]) > 0.5, 1,0)
	MergedTable[i,c('FCPGreaterRedution')] = ifelse( (as.numeric(MergedTable[i,c('FCP_1')]) <= 50), NA, MergedTable[i,c('FCPGreaterRedution')])
}

### If the diff < 42, then define it as non-response (Jim said NA, but changed to nonreponse later)
### Then changed to NA, again
Diff = MergedTable[,c('DiffStopStart')]
MergedTable[!is.na(Diff) & (Diff<42),c('PCDAIRemission','PCDAIResponse','FCP50','FCPResponse','FCPGreaterRedution')] = NA

### 

### Some special samples
## 7014 FCP 1997	1997	1123	NA
MergedTable['7014','FCP50'] = 0
MergedTable['7014','FCPResponse'] = 0
MergedTable['7014','FCPGreaterRedution'] = 0
## 7012 FCP 473	1364	669	NA
MergedTable['7012','FCP50'] = 0
MergedTable['7012','FCPResponse'] = 0
MergedTable['7012','FCPGreaterRedution'] = 0
## 5008 FCP 852	338	332	NA
MergedTable['5008','FCP50'] = 0
MergedTable['5008','FCPResponse'] = 0
MergedTable['5008','FCPGreaterRedution'] = 1
## 6009 FCP 1515	1086	242	NA
MergedTable['6009','FCP50'] = 0
MergedTable['6009','FCPResponse'] = 1
MergedTable['6009','FCPGreaterRedution'] = 1
## 5005 FCP 1896	1800	929	NA
MergedTable['5005','FCP50'] = 0
MergedTable['5005','FCPResponse'] = 0
MergedTable['5005','FCPGreaterRedution'] = 1
## 7003 FCP NA	1508	456	661
MergedTable['7003','FCP50'] = 0
MergedTable['7003','FCPResponse'] = 0
MergedTable['7003','FCPGreaterRedution'] = 1
## 5025 FCP NA	457	816	54
MergedTable['5025','FCP50'] = 0
MergedTable['5025','FCPResponse'] = 1
MergedTable['5025','FCPGreaterRedution'] = 1


##Rules for defining clinical response or remission
##Clinical remission – final PCDAI<=10
##Clinical response – final PCDAI ≤10 or a 15 point reduction from week 0
##If week 8 PCDAI is missing, we can impute response or remission using PUCAI or the SSTOP reason. 
##If the PUCAI decreases by 20 points or more from baseline the participant is categorized as a responder. Remission is categorized as missing.
##If the PUCAI decreases by <20 points from baseline the participant is categorized as a non-responder and as not achieving clinical remission. 

## 6009 PUCAI 55	20	20	NA
MergedTable['6009','PUCAIResponse'] = 1
MergedTable['6009','PCDAIResponse'] = 1
MergedTable['6009','PCDAIRemission'] = NA
## 7012 PUCAI 40	35	30	NA
MergedTable['7012','PUCAIResponse'] = 0
MergedTable['7012','PCDAIResponse'] = 0
MergedTable['7012','PCDAIRemission'] = 0
### 5002 PUCAI 75	10	50	40, PCDAI of this sample has been corrected
#MergedTable['5002','PUCAIResponse'] = 1
#MergedTable['5002','PCDAIResponse'] = 1
## 5037 PUCAI 35	25	15	15
MergedTable['5037','PUCAIResponse'] = 1
MergedTable['5037','PCDAIResponse'] = 1
MergedTable['5037','PCDAIRemission'] = NA
## 6005 PUCAI 30	40	15	10
MergedTable['6005','PUCAIResponse'] = 1
MergedTable['6005','PCDAIResponse'] = 1
MergedTable['6005','PCDAIRemission'] = NA
## 6016 PUCAI 25	15	10	15
MergedTable['6016','PUCAIResponse'] = 0
MergedTable['6016','PCDAIResponse'] = 0
MergedTable['6016','PCDAIRemission'] = 0

## Jim: An important clarification
## we should not use 5049 data for anything that is treatment specific. 
## This person was actually receiving both diet therapy and antiTNF therapy at the same time.
MergedTable['5049',c('PCDAIRemission','PCDAIResponse','FCP50','FCPResponse','FCPGreaterRedution')] = NA

####!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
### Jim: For 6017 FCP, we use the 3rd time point as the final time point
## FCP:1440	369	299	221, it would be defined as non-response using 3rd time point
## The treatment time is 31 days, so all the responses are defined as non-response
## Here, I did not specifically use the 3rd time point to define non-response,
## because it has been defined by treatment time crition

### Jim: define 6017 FCP reduction as 1
MergedTable['6017','FCPGreaterRedution'] = 1

### Merge FCP and PCDAI
### Use FCP reponse first, if NA, then use FCP reduction, if still NA, use PCDAI response
MergedTable[,'MergedResponse'] = MergedTable[,'FCPResponse']
MergedTable[is.na(MergedTable[,'MergedResponse']),'MergedResponse'] = MergedTable[is.na(MergedTable[,'MergedResponse']),'FCPGreaterRedution']
MergedTable[is.na(MergedTable[,'MergedResponse']),'MergedResponse'] = MergedTable[is.na(MergedTable[,'MergedResponse']),'PCDAIResponse']



write.table(MergedTable, file = "Final_Outcome_Table_ReFormat_08_11_2014.xls", quote = F, sep = "\t",row.names = TRUE,col.names = NA)


table(MergedTable[,c('FCPResponse','PCDAIResponse')],useNA='always')