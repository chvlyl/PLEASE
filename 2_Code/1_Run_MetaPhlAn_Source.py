import glob,re,os


class MetaPhlAn:
    def __init__ (self, inputFiles):
        self.inputFiles = inputFiles
        self.sample2files = {}
        self.relFiles = []
        self.outputFolder = ''
        #print inputFiles

    def setOutputFolder(self,outputFolder):
        self.outputFolder = outputFolder
        if not os.path.exists(self.outputFolder):
            os.system('mkdir %s' % self.outputFolder)
        #else:
        #    os.system('rm %s/*.txt' % self.outputFolder)

    def getSampleNameByFileName(self):
        for inFile in self.inputFiles:
            sampleName = inFile.split('/')[-1].split('_')[0]
            if sampleName not in self.sample2files:
                self.sample2files[sampleName] = []
            self.sample2files[sampleName].append(inFile)


    def getSampleNameByFolder(self):
        for inFile in self.inputFiles:
            sampleName = inFile.split('/')[-2]
            if sampleName not in self.sample2files:
                self.sample2files[sampleName] = []
            self.sample2files[sampleName].append(inFile)



    def getRelFileName(self):
        for sampleName in self.sample2files:
            self.relFiles.append('rel_ab__%s.txt' % (sampleName))

    def run(self):
        #'rel_ab', 'reads_map', 'clade_profiles', 'marker_ab_table', 'marker_pres_table'
        #print self.sample2files
        for sampleName in sorted(self.sample2files):
            if not os.path.exists('%s/%s.bt2out.txt' % (self.outputFolder,sampleName)):
                inFiles = self.sample2files[sampleName]
                if re.search('.fna',inFiles[0]):fafq = 'multifasta'
                if re.search('.fastq',inFiles[0]):fafq = 'multifastq'
                #### rel_ab
                CMD = 'python /home/eric/3_PLEASE/10_PLEASE_Two_Batch_Data/1_MetaPhlAn/metaphlan_1_7.py  --input_type %s %s --bowtie2db /home/eric/3_PLEASE/7_MetaPhlAn/MetaPhlAn_1_6_7/bowtie2db/mpa --nproc 20 -t rel_ab -o %s/rel_ab__%s.txt --bowtie2out %s/%s.bt2out.txt' % (fafq,(',').join(inFiles),self.outputFolder,sampleName,self.outputFolder,sampleName)
                print CMD
                os.system(CMD)
                #### clade_profiles
                CMD = 'python /home/eric/3_PLEASE/10_PLEASE_Two_Batch_Data/1_MetaPhlAn/metaphlan_1_7.py  %s/%s.bt2out.txt --nproc 20 -t clade_profiles -o %s/clade_profiles__%s.txt' % (self.outputFolder,sampleName,self.outputFolder,sampleName)
                print CMD
                os.system(CMD)
            else:
                #### rel_ab
                CMD = 'python /home/eric/3_PLEASE/10_PLEASE_Two_Batch_Data/1_MetaPhlAn/metaphlan_1_7.py  %s/%s.bt2out.txt --nproc 20 -t rel_ab -o %s/rel_ab__%s.txt' % (self.outputFolder,sampleName,self.outputFolder,sampleName)
                print CMD
                os.system(CMD)
                #### clade_profiles
                CMD = 'python /home/eric/3_PLEASE/10_PLEASE_Two_Batch_Data/1_MetaPhlAn/metaphlan_1_7.py  %s/%s.bt2out.txt --nproc 20 -t clade_profiles -o %s/clade_profiles__%s.txt' % (self.outputFolder,sampleName,self.outputFolder,sampleName)
                print CMD
                os.system(CMD)


    ####-- MetaPhlAn output --####
    #k__Bacteria|p__Proteobacteria|c__Betaproteobacteria	4.32758
    #k__Bacteria|p__Actinobacteria|c__Actinobacteria	0.54228
    #k__Bacteria|p__Firmicutes|c__Clostridia	0.2401
    def mergeResult(self,outFile = 'K_Merge_Rel_MetaPhlAn_Result.xls'):
        sub2tax = {}
        taxIndex = [] ## Use as column names when output
        for relFile in self.relFiles:
            sampleName = relFile.split('.')[0].split('__')[-1]
            op = file(self.outputFolder+'/'+relFile,'r')
            for line in op:
                line = line.rstrip()
                line = line.replace('\'','')
                arr  = line.split('\t')
                tax = arr[0].split('|')
                val = arr[1]
                ###some values be like 9e_05, how stupid it is!!
                val = val.replace('e_','e-')
                ###
                ## find the union of the column names
                if tax[-1].split('__')[0] == 'k':
                    #k p c o f g s
                    if tax[-1] not in taxIndex: taxIndex.append(tax[-1]) 
                    if sampleName not in sub2tax:sub2tax[sampleName] = {}
                    sub2tax[sampleName][tax[-1]] = val
            op.close()
        opt = file('No_Transpse_'+outFile,'w')
        Sample2Outline = ['NA']*(len(sub2tax.keys())+1)
        Sample2Outline[0] = ['Sample'] + taxIndex
        ind = 0
        opt.write('Sample\t%s\n'% (('\t').join(taxIndex)))
        for sName in sorted(sub2tax.keys()):
            pLine = [sName.replace('Sample_','')]
            for clade in taxIndex:
                if clade not in sub2tax[sName]:
                    sub2tax[sName][clade] = 0
                pLine.append(str(sub2tax[sName][clade]))
            opt.write('%s\n'% (('\t').join(pLine)))
            ind = ind + 1
            #print taxIndex
            Sample2Outline[ind] = pLine
        opt.close
        ##
        opt = file(outFile,'w')
        for j in range(len(Sample2Outline[0])):
            ppLine = []
            for i in range(ind+1):
                ppLine.append(Sample2Outline[i][j])
            opt.write('%s\n' % ('\t').join(ppLine))
        opt.close


if __name__ == '__main__':
    
    ## Change the following paramters
    #folder = '/home/eric/3_PLEASE/7_MetaPhlAn/4_dChip_Model/9_MetaSim/SimLC_Species_20_EqualPer_Sample20_Variated_Depth_v2'
    #files = glob.glob(folder + '/*.fna')
    #outFolder = '2_Simulatioin_Data_Low_Complex_2013_Feb_28_7pm'

    folder = '/media/THING2/eric/0_PLEASE_Fastq/'
    files = glob.glob(folder + 'Sample*/*.gz')
    outFolder = 'MetaPhlAn_Result'

    meta = MetaPhlAn(files)
    meta.setOutputFolder(outFolder)
    if files[0].split('.')[-1] == 'fna':
        meta.getSampleNameByFileName()
    if files[0].split('.')[-1] == 'gz':
        meta.getSampleNameByFolder()
    meta.getRelFileName()
    #meta.run()
    meta.mergeResult()