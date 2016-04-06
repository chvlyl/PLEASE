TLevel = 'F'
metafile = paste('/home/eric/3_PLEASE/11_COMBO_Kids_Shortgun_MetaPhlAn/',
                  TLevel,'_Merge_Rel_MetaPhlAn_Result.xls',sep='')
Meta    = read.table(metafile,sep='\t',header=T,row.names = 1,check.names=F)

remove.index = grep('_unclassified',rownames(Meta))
if (length(remove.index)>0){
Meta.remove = Meta[-remove.index,]
Meta.nor = apply(Meta.remove,2,function(X){X/sum(X)})
na.index = is.na(colSums(Meta.nor))
Meta.nor = Meta.nor[,!na.index]*100
write.table(Meta.nor, file = paste(TLevel,'_Remove_unclassfied_Renormalized_Merge_Rel_MetaPhlAn_Result.xls',sep=''),
                    quote = F, sep = "\t",row.names = T,col.names = NA)
}else{
  write.table(Meta, file = paste(TLevel,'_Remove_unclassfied_Renormalized_Merge_Rel_MetaPhlAn_Result.xls',sep=''),
                    quote = F, sep = "\t",row.names = T,col.names = NA)

}