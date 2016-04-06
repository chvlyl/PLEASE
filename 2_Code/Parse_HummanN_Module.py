import glob,re



##### Load ID to name
ID2Name = {}
inputfile = '/media/THING2/rohinis/please_humann/humann-0.99/data/map_kegg.txt'
opin = file(inputfile,'r')
for Line in opin:
    Line = Line.rstrip()
    Array = Line.split('\t')
    ID = Array[0]
    Name  = Array[1]
    ID2Name[ID] = Name
opin.close()


##/media/THING2/rohinis/please_humann/humann-0.99/output
##4000_filtered.fasta_kegg_usearch_04b-hit-keg-mpt-cop-nul-nve-nve.txt pathway
##4000_filtered.fasta_kegg_usearch_04b-hit-keg-mpm-cop-nul-nve-nve.txt module

TotalSamples = []
TotalGene = {}
Sample2GeneAbu = {}
Sample2TotalAbu = {}
####

COMBO_files = glob.glob('/media/THING2/rohinis/please_humann/humann-0.99/output/*_filtered.fasta_kegg_usearch_04b-hit-keg-mpm-cop-nul-nve-nve.txt') 
PLEASE_files = glob.glob('/media/THING2/rohinis/please_humann/*_filtered.fasta_kegg_usearch_04b-hit-keg-mpm-cop-nul-nve-nve.txt') 
files = COMBO_files+PLEASE_files
for inputfile in files:
    Sample = inputfile.split('/')[-1].split('_')[0]
    print Sample
    opin = file(inputfile,'r')
    Gene2Abu = {}
    for Line in opin:
        if re.search('^PID',Line):continue
        Line = Line.rstrip()
        Array = Line.split('\t')
        Gene = Array[0]
        Abu  = Array[1]
        Gene2Abu[Gene] = float(Abu)
        TotalGene[Gene] = 1
    opin.close()
    Sample2TotalAbu[Sample] = sum(Gene2Abu.values())
    Sample2GeneAbu[Sample] = Gene2Abu
    if Sample2TotalAbu[Sample] > 0:
        TotalSamples.append(Sample)

#print Sample2TotalAbu

opt = file('Module_Abundance_from_04b_mpt.txt','w')
#opt = file('Module_Abundance_from_04b_mpt.txt','w')
opt.write('PID\t%s\n' % (('\t').join(TotalSamples)))
for G in TotalGene:
    if G in ID2Name:
        ID = ID2Name[G]
        ID = ID.replace('=>','to')
        ID = ID.replace('+','plus')
        ID = ID.replace(':',' ')
        ID = ID.replace('\'',' ')
        ID = ID.replace('\"',' ')
        ID = ID.replace(',',' ')
        ID = ID.replace('/','')
        ID = ID.replace('-',' ')
        ID = ID.replace('(',' ')
        ID = ID.replace(')',' ')
        ID = ID.replace('   ',' ')
        ID = ID.replace('  ',' ')
        ID = ID.replace(' ','_')
        PrintLine = [G+'__'+ID]
    else:
        PrintLine = [G+'__NA']
    for S in TotalSamples:
        if G not in Sample2GeneAbu[S]:
            Sample2GeneAbu[S][G] = 0
        RelAbu = float(Sample2GeneAbu[S][G])/float(Sample2TotalAbu[S])*100
        PrintLine.append(str(RelAbu))
    opt.write('%s\n' % (('\t').join(PrintLine)))
opt.close()




