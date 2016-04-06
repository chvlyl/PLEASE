
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
source('load.R')

shinyServer(function(input, output) {
  
  ##############################
  output$heatmapTaxa <- renderPlot({
    ind <- intersect(rownames(nitrogen),rownames(taxa.data))
    ind.treat <- rownames(sample.info)
    ind.resp  <- rownames(sample.info)
    ind.group <- rownames(subset(sample.info,Type==input$selectSamples))
    #print(input$selectResponse)
    if(input$selectSamples != 'COMBO' & input$selectTreatment != 'All'){
      ind.treat <- rownames(subset(sample.info,Treatment.Specific == input$selectTreatment))
    }
    
    if(input$selectSamples != 'COMBO' & input$selectResponse != 'All'){
      ind.resp <- rownames(subset(sample.info,Response == input$selectResponse))
    }
    ind <- Reduce(intersect, list(ind, ind.treat,ind.resp,ind.group))
    ##
    pathway.bact.cor <- cor(nitrogen[ind,colSums(nitrogen[ind,])>0],
                            taxa.data[ind,colSums(taxa.data[ind,])>0],
                            method='spearman')
    plot.correlation.heatmap(pathway.bact.cor,row.filter=0,col.filter=input$maxCor)
  })
  
  ##############################
  output$corplotTaxa <- renderPlot({
    ind <- intersect(rownames(nitrogen),rownames(taxa.data))
    ind.treat <- rownames(sample.info)
    ind.resp  <- rownames(sample.info)
    ind.group <- rownames(subset(sample.info,Type==input$selectSamples))
    print(input$selectResponse)
    if(input$selectSamples != 'COMBO' & input$selectTreatment != 'All'){
      ind.treat <- rownames(subset(sample.info,Treatment.Specific == input$selectTreatment))
    }
    
    if(input$selectSamples != 'COMBO' & input$selectResponse != 'All'){
      ind.resp <- rownames(subset(sample.info,Response == input$selectResponse))
    }
    ind <- Reduce(intersect, list(ind, ind.treat,ind.resp,ind.group))
    ####
    par(mfrow=c(4,5))
    for (ng in colnames(nitrogen)){
      plot(nitrogen[ind,ng],taxa.data[ind,input$selectTaxa],
           xlab=ng,ylab=input$selectTaxa,main='')
      mtext(paste('cor =',signif(cor(nitrogen[ind,ng],taxa.data[ind,input$selectTaxa],method='spearman'),3)))
    }
  })
  
  #   output$fcpplot <- renderPlot({
  #     if (input$selectResponse=='All'){
  #       ind <- intersect(rownames(nitrogen),
  #                        rownames(subset(sample.info,
  #                       Type==input$selectSamples & !is.na(FCP))))
  #     } else{
  #       ind <- intersect(rownames(nitrogen),
  #                        rownames(subset(sample.info,
  #                 Type==input$selectSamples & 
  #                 Response == input$selectResponse & !is.na(FCP))))
  #     }
  #     par(mfrow=c(4,5))
  #     for (ng in colnames(nitrogen)){
  #       plot(nitrogen[ind,ng],log(sample.info[ind,'FCP']),
  #            xlab=ng,ylab='logFCP',main='')
  #       mtext(paste('cor =',signif(cor(nitrogen[ind,ng],log(sample.info[ind,'FCP']),
  #                                      method='spearman'),3)))
  #     }
  #   })
  #   
  
  
  ##############################
  ### metabolites
  output$heatmapMetab <- renderPlot({
    ind <- intersect(rownames(nitrogen),rownames(kmdata.nor))
    ind.treat <- rownames(sample.info)
    ind.resp  <- rownames(sample.info)
    ind.group <- rownames(subset(sample.info,Type==input$selectSamplesMetab))
    #print(input$selectResponseMetab)
    if(input$selectSamplesMetab != 'COMBO' & input$selectTreatmentMetab != 'All'){
      ind.treat <- rownames(subset(sample.info,Treatment.Specific == input$selectTreatmentMetab))
    }
    
    if(input$selectSamplesMetab != 'COMBO' & input$selectResponseMetab != 'All'){
      ind.resp <- rownames(subset(sample.info,Response == input$selectResponseMetab))
    }
    ind <- Reduce(intersect, list(ind, ind.treat,ind.resp,ind.group))
    ###
    pathway.bact.cor <- cor(nitrogen[ind,colSums(nitrogen[ind,])>0],
                            kmdata.nor[ind,colSums(kmdata.nor[ind,])>0],
                            method='spearman')
    plot.correlation.heatmap(pathway.bact.cor,row.filter=0,col.filter=input$maxCorMetab)
  })
  
  
  ##############################
  output$corplotMetab <- renderPlot({
    ind <- intersect(rownames(nitrogen),rownames(kmdata.nor))
    ind.treat <- rownames(sample.info)
    ind.resp  <- rownames(sample.info)
    ind.group <- rownames(subset(sample.info,Type==input$selectSamplesMetab))
    if(input$selectSamplesMetab != 'COMBO' & input$selectTreatmentMetab != 'All'){
      ind.treat <- rownames(subset(sample.info,Treatment.Specific == input$selectTreatmentMetab))
    }
    
    if(input$selectSamplesMetab != 'COMBO' & input$selectResponseMetab != 'All'){
      ind.resp <- rownames(subset(sample.info,Response == input$selectResponseMetab))
    }
    ind <- Reduce(intersect, list(ind, ind.treat,ind.resp,ind.group))
    ####
    par(mfrow=c(4,5))
    for (ng in colnames(nitrogen)){
      plot(nitrogen[ind,ng],kmdata.nor[ind,input$selectMetab],
           xlab=ng,ylab=input$selectMetab,main='')
      mtext(paste('cor =',signif(cor(nitrogen[ind,ng],kmdata.nor[ind,input$selectMetab],method='spearman'),3)))
    }
  })
  
})
