#devtools::install_github("raivokolde/pheatmap")
library(pheatmap)
sample.info <- read.csv('data/2015_02_13_Processed_Sample_Information.csv',row.names=1)
gene.data <- read.csv('data/Gene_Filtered_Abundance.csv',row.names=1)
taxa.data <- read.csv('data/G_Processed_MetaPhlAn_Abundance.csv',row.names=1)
kmdata.nor <- t(read.csv('data/Known_Metabolite_Normalized_Abundance.csv',check.names = FALSE,row.names=1))
nitrogen.gene <- c('K00370__nitrate_reductase_1_alpha_subunit',
                   'K00371__nitrate_reductase_1_beta_subunit','K03635__molybdenum_cofactor_biosynthesis_protein_E','K03831__molybdopterin_biosynthesis_protein_Mog','K07715__two_component_system_NtrC_family_response_regulator_YfhA','K04752__nitrogen_regulatory_protein_P_II_2','K04751__nitrogen_regulatory_protein_P_II_1','K07687__two_component_system_NarL_family_captular_synthesis_response','K00363__nitrite_reductase_NAD_P_H_small_subunit','K01990__ABC_2_type_transport_system_ATP_binding_protein','K03637__molybdenum_cofactor_biosynthesis_protein_C','K03753__molybdopterin_guanine_dinucleotide_biosynthesis_protein_B','K03638__molybdenum_cofactor_biosynthesis_protein_B','K02806__PTS_system_nitrogen_regulatory_IIA_component')
nitrogen <- gene.data[,nitrogen.gene]



plot.correlation.heatmap = function(cor.matrix,
                                    row.filter=0.5,
                                    col.filter=0.5
){
  cor.matrix <- cor.matrix[
    apply(cor.matrix,1,function(X){max(abs(X),na.rm=TRUE)>row.filter}),
    apply(cor.matrix,2,function(X){max(abs(X),na.rm=TRUE)>col.filter})
    ]
  
  bk <- unique(c(seq(-1,-0.4,length=10),
                 seq(-0.4,0.4,length=50),
                 seq(0.4,1,length=10)))
  hmcols<- colorRampPalette(c('#4575b4','#91bfdb','#e0f3f8',
                              '#ffffbf','#fee090','#fc8d59','#d73027'
  ))(length(bk)-1)
  
  pheatmap(cor.matrix, 
           scale='none',fontsize_row = 10, 
           clustering_distance_cols = "manhattan",
           clustering_distance_rows = "manhattan",
           cluster_cols = TRUE,
           color =hmcols, breaks=bk,
           cellwidth = 10, cellheight = 10
  )                              
}

