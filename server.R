options(shiny.maxRequestSize= 1000*1024^2)
options(shiny.sanitize.errors = FALSE)
source("boxColor.R")
source("forestplot.R")
source("superpc.R")
source("pcm_cv.R")
source("superpccox.R")
source("pcm_cv2.R")
source("superpccon.R")
source("pcm_cv3.R")

function(input, output, session){
  
  data_input <- reactive({
    if(input$file1 == 'Example'){
      d <- read.csv("data/poster_data.csv", header =T, sep =",", stringsAsFactors = F)
    }
    else if(input$file1 == 'load_my_own'){
      inFile <- input$file2
      if (is.null(inFile))
        return(NULL)
      else if(grepl(".xlsx", inFile[1])) { d = read.xlsx(as.character(inFile$datapath), colNames = TRUE, rowNames = F, as.is = T) }
      else if(grepl(".csv", inFile[1])) { d = read.csv(as.character(inFile$datapath), header = TRUE, sep = ",", stringsAsFactors = F, as.is = T, fill = T) }
      else if(grepl(".txt", inFile[1])) { d = read.table(as.character(inFile$datapath), header = TRUE, sep = "\t", stringsAsFactors = F, as.is = T, fill = T) }
    }
    else 
      return(NULL)
    # dim(data)
    Dataset <- data.frame(d)
    return(as.data.frame(Dataset))
  })
  
  
  output$Forestplot <- renderPlot({
    if(!is.null(data_input()))
    {
      data <-  data_input()
      data <- data[order(-data$ID),] 
      data$boxcolor <- apply(data[, c(3, 4)], 1, function(x) boxColor(low= x[1], high= x[2], col_low= input$col_low, col_mid= input$col_mid, col_high= input$col_high))
      forestplot(CI_Data = data, lf_label = colnames(data)[1], left_label = input$Left_text_label, right_label = input$Right_text_label, fontsize= as.numeric(input$font_size), ID_pos2= input$ID_position2, scaledata = as.character(input$scaledata), legendfontsize= as.numeric(input$legend_font_size))
    }
    else
      return(NULL)
  })
  
  output$downloadEx <- downloadHandler(
    
    filename <- function() {
      paste('Example ds', Sys.time(),'.csv', sep='')
    },
    content <- function(file) {
      ds2 <- data_input()
      write.csv(ds2, file, row.names = FALSE)
    }
  )
  
  output$downloadFP <- downloadHandler(
    filename <- function() {
      pdf_file <<- as.character(input$fname)
      paste('FP_', pdf_file, Sys.time(),'.pdf', sep='')
    },
    content <- function(file) {
      pdf(file=paste(pdf_file,".pdf",sep="") , height= 12, width=8)
      #plot_fp()
      data <-  data_input()
      data <- data[order(-data$ID),] 
      data$boxcolor <- apply(data[, c(3, 4)], 1, function(x) boxColor(low= x[1], high= x[2], col_low= input$col_low, col_mid= input$col_mid, col_high= input$col_high))
      forestplot(CI_Data = data, lf_label = colnames(data)[1], left_label = input$Left_text_label, right_label = input$Right_text_label, fontsize= as.numeric(input$font_size), ID_pos2= input$ID_position2, scaledata = as.character(input$scaledata), legendfontsize= as.numeric(input$legend_font_size))
      dev.off()
      file.copy(paste(pdf_file,'.pdf', sep='') ,file, overwrite=TRUE)
    })
  
  data_input2 <- reactive({
    if(input$file22 == 'Example2'){
      d2 <- read.csv("data/superPC_data.csv", header =T, sep =",", stringsAsFactors = F)
    }
    else if(input$file22 == 'load_my_own'){
      inFile <- input$file221
      if (is.null(inFile))
        return(NULL)
      else if(grepl(".xlsx", inFile[1])) { d2 = read.xlsx(as.character(inFile$datapath), colNames = TRUE, rowNames = F, as.is = T) }
      else if(grepl(".csv", inFile[1])) { d2 = read.csv(as.character(inFile$datapath), header = TRUE, sep = ",", stringsAsFactors = F, as.is = T, fill = T) }
      else if(grepl(".txt", inFile[1])) { d2 = read.table(as.character(inFile$datapath), header = TRUE, sep = "\t", stringsAsFactors = F, as.is = T, fill = T) }
    }
    else 
      return(NULL)
    # dim(data)
    Dataset2 <- data.frame(d2)
    return(as.data.frame(Dataset2))
  })
  
  data_input3 <- reactive({
    if(input$file22 == 'Example2'){
      d2 <- read.csv("data/superPC_data.csv", header =F, sep =",", stringsAsFactors = F, skip =2)
    }
    else if(input$file22 == 'load_my_own'){
      inFile <- input$file221
      if (is.null(inFile))
        return(NULL)
      else if(grepl(".xlsx", inFile[1])) { d2 = read.xlsx(as.character(inFile$datapath), colNames = TRUE, rowNames = F, as.is = T) }
      else if(grepl(".csv", inFile[1])) { d2 = read.csv(as.character(inFile$datapath), header = FALSE, sep = ",", stringsAsFactors = F, as.is = T, fill = T, skip =2) }
      else if(grepl(".txt", inFile[1])) { d2 = read.table(as.character(inFile$datapath), header = FALSE, sep = "\t", stringsAsFactors = F, as.is = T, fill = T, skip =2) }
    }
    else 
      return(NULL)
    # dim(data)
    Dataset2 <- data.frame(d2)
    return(as.data.frame(Dataset2))
  })
  
  output$downloadEx2 <- downloadHandler(
    
    filename <- function() {
      paste('Example ds Super PC', Sys.time(),'.csv', sep='')
    },
    content <- function(file) {
      ds4 <- data_input2()
      write.csv(ds4, file, row.names = FALSE)
    }
  )
  
  data_input2fold <- reactive({
    if(input$file22fold == 'Example2'){
      d2 <- read.csv("data/foldid1.csv", header =T, sep =",", stringsAsFactors = F)
    }
    else if(input$file22fold == 'load_my_own'){
      inFile <- input$file221fold
      if (is.null(inFile))
        return(NULL)
      else if(grepl(".xlsx", inFile[1])) { d2 = read.xlsx(as.character(inFile$datapath), colNames = TRUE, rowNames = F, as.is = T) }
      else if(grepl(".csv", inFile[1])) { d2 = read.csv(as.character(inFile$datapath), header = TRUE, sep = ",", stringsAsFactors = F, as.is = T, fill = T) }
      else if(grepl(".txt", inFile[1])) { d2 = read.table(as.character(inFile$datapath), header = TRUE, sep = "\t", stringsAsFactors = F, as.is = T, fill = T) }
    }
    else 
      return(NULL)
    # dim(data)
    Dataset2 <- data.frame(d2)
    return(as.data.frame(Dataset2))
  })
  
  output$downloadEx2fold <- downloadHandler(
    
    filename <- function() {
      paste('Example ds', Sys.time(),'.csv', sep='')
    },
    content <- function(file) {
      dsfold2 <- data_input2fold()
      write.csv(dsfold2, file, row.names = FALSE)
    }
  )
  
  
  super_PC <- reactive({
    input$goButton3
    
    validate(
      need(!is.null(data_input2()) & !is.null(data_input3()), label = "Data set")
    )
    
    if(!is.null(data_input2()) & !is.null(data_input3()))
    {
      data1 <- data_input2()
      data2 <- data_input3()
      foldid <- data_input2fold()
      
      if (input$foldid1 == 0) {
        cv.order = NULL
        splitIndex = NULL
        withProgress(message = 'Iterations', value = 0, {
          
          sup <- isolate(superpc(data1, data2, nstep = as.integer(input$cutoff1), prop = as.numeric(as.integer(input$split1)/100), nfold = as.integer(input$nfold3), cv.order = cv.order, splitIndex = splitIndex ))
        })
      } else if (input$foldid1 == 1) {
        cv.order = as.vector(foldid[, 2])
        splitIndex = as.vector(foldid[, 3])
        withProgress(message = 'Iterations', value = 0, {
          
          sup <-isolate(superpc(data1, data2, nstep = as.integer(input$cutoff1), prop = as.numeric(as.integer(input$split1)/100), nfold = as.integer(input$nfold3), cv.order = cv.order, splitIndex = splitIndex ))
        })
      }
      
    }
    else
      return(NULL)
  })
  
  output$SuperPC <- DT::renderDataTable({
    input$goButton3
    
    validate(
      need(!is.null(data_input2()) & !is.null(data_input3()), label = "Data sets")
    )
    isolate(DT::datatable(super_PC()[[3]], options = list(
      lengthMenu = list(c(5, 10, -1), c('5', '10', 'All')),
      pageLength = 10)))
  })
  
  output$predictplot <- renderPlot({
    input$goButton3
    dat <- super_PC()[[2]]
    
    
    if (input$Predicted1 == 1) {
      counts <- table( dat$pred.discrete, dat$group_label)
      isolate(barplot(counts, col=c("blue","grey"), main = "Barplot between Observed and Predicted", 
                      legend = rownames(counts), beside=TRUE, args.legend = list(x = "topleft")))
      
    } else if (input$Predicted1 == 0) {
      isolate(boxplot(dat$pred.contiuous~dat$group_label, main = "Box plot of Predicted Principal Component between Observed groups"))
    } 
  })
  
  output$ex_out1 <- renderPrint({
    input$goButton3
    dat <- super_PC()[[2]]
    
    if (input$Predicted1 == 1) {
      isolate(pander(table(dat$pred.discrete, dat$group_label)))
      
    } else if (input$Predicted1 == 0) {
      isolate(pander(tapply(dat$pred.contiuous, dat$group_label, summary)))
    } 
  })
  
  output$ex_out2 <- renderPrint({
    input$goButton3
    dat <- super_PC()[[2]]
   
    if (input$Predicted1 == 1) {
      counts <- table(dat$pred.discrete, dat$group_label)
      isolate(pander(chisq.test(counts))) 
      
    } else if (input$Predicted1 == 0) {
      isolate(pander(t.test(dat$pred.contiuous~dat$group_label)))
    } 
  })
  
  output$ex_p <- renderPrint({
    input$goButton3
    validate(
      need(!is.null(data_input2()) & !is.null(data_input3()), label = "Data set")
    )
    isolate(cat(paste("The p-value for the most significant Principal component is = ", round(super_PC()[[1]],3), ".", sep = "")))
  })
  
  output$downloadSuperPC <- downloadHandler(
    
    filename <- function() {
      paste('Super PC Results', Sys.time(),'.csv', sep='')
    },
    content <- function(file) {
      ds5 <- super_PC()[[3]]
      write.csv(ds5, file, row.names = TRUE)
    }
  )
  
  output$downloadfoldid1 <- downloadHandler(
    
    filename <- function() {
      paste('Fold IDs', Sys.time(),'.csv', sep='')
    },
    content <- function(file) {
      dsfold <- data.frame(super_PC()[[4]])
      colnames(dsfold) <- c('foldid', 'resample')
      write.csv(dsfold, file, row.names = TRUE)
    }
  )
  
  output$pv <- renderUI({
    hs1 <- paste("&emsp;")
    hs2 <- paste("Association between Predicted Principal Component with Observed Outcome")
    HTML(paste(h2(strong(hs2)), hs1, sep = '<br/>'))
  })
  
  
  output$pv2 <- renderUI({
    hs1 <- paste("&emsp;")
    hs2 <- paste("Plots and Statistical Results for Predicted Principal Component between Observed Outcome")
    HTML(paste(hs1, h2(strong(hs2)), hs1, sep = '<br/>'))
  })
  
  
  output$title <- renderUI({
    hs1 <- paste("&emsp;")
    hs2 <- paste("Univariate logistic regresssion of genes associated with outcome to generate Principal components")
    HTML(paste(hs1, h2(strong(hs2)), hs1, sep = '<br/>'))
  })
  
  data_input4 <- reactive({
    if(input$file4 == 'Example4'){
      d4 <- read.csv("data/file1.csv")
    }
    else if(input$file4 == 'load_my_own'){
      inFile <- input$file41
      if (is.null(inFile))
        return(NULL)
      else if(grepl(".xlsx", inFile[1])) { d4 = read.xlsx(as.character(inFile$datapath), colNames = TRUE, rowNames = F, as.is = T) }
      else if(grepl(".csv", inFile[1])) { d4 = read.csv(as.character(inFile$datapath), header = TRUE, sep = ",", stringsAsFactors = F, as.is = T, fill = T) }
      else if(grepl(".txt", inFile[1])) { d4 = read.table(as.character(inFile$datapath), header = TRUE, sep = "\t", stringsAsFactors = F, as.is = T, fill = T) }
    }
    else 
      return(NULL)
    # dim(data)
    Dataset4 <- data.frame(d4)
    return(as.data.frame(Dataset4))
  })
  
  
  data_input5 <- reactive({
    if(input$file5 == 'Example5'){
      d5 <- read.csv("data/file2.csv", stringsAsFactors = F)
    }
    else if(input$file5 == 'load_my_own'){
      inFile <- input$file51
      if (is.null(inFile))
        return(NULL)
      else if(grepl(".xlsx", inFile[1])) { d5 = read.xlsx(as.character(inFile$datapath), colNames = TRUE, rowNames = F, as.is = T) }
      else if(grepl(".csv", inFile[1])) { d5 = read.csv(as.character(inFile$datapath), header = TRUE, sep = ",", stringsAsFactors = F, as.is = T, fill = T) }
      else if(grepl(".txt", inFile[1])) { d5 = read.table(as.character(inFile$datapath), header = TRUE, sep = "\t", stringsAsFactors = F, as.is = T, fill = T) }
    }
    else 
      return(NULL)
    # dim(data)
    Dataset5 <- data.frame(d5)
    return(as.data.frame(Dataset5))
  })
  
  output$downloadEx3 <- downloadHandler(
    
    filename <- function() {
      paste('Example ds Super PC', Sys.time(),'.csv', sep='')
    },
    content <- function(file) {
      ds6 <- data_input4()
      write.csv(ds6, file, row.names = FALSE)
    }
  )
  
  output$downloadEx4 <- downloadHandler(
    
    filename <- function() {
      paste('Example ds Super PC', Sys.time(),'.csv', sep='')
    },
    content <- function(file) {
      ds7 <- data_input5()
      write.csv(ds7, file, row.names = FALSE)
    }
  )
  
  data_input2fold2 <- reactive({
    if(input$file22fold2 == 'Example2'){
      d2 <- read.csv("data/foldid2.csv", header =T, sep =",", stringsAsFactors = F)
    }
    else if(input$file22fold2 == 'load_my_own'){
      inFile <- input$file221fold2
      if (is.null(inFile))
        return(NULL)
      else if(grepl(".xlsx", inFile[1])) { d2 = read.xlsx(as.character(inFile$datapath), colNames = TRUE, rowNames = F, as.is = T) }
      else if(grepl(".csv", inFile[1])) { d2 = read.csv(as.character(inFile$datapath), header = TRUE, sep = ",", stringsAsFactors = F, as.is = T, fill = T) }
      else if(grepl(".txt", inFile[1])) { d2 = read.table(as.character(inFile$datapath), header = TRUE, sep = "\t", stringsAsFactors = F, as.is = T, fill = T) }
    }
    else 
      return(NULL)
    # dim(data)
    Dataset2 <- data.frame(d2)
    return(as.data.frame(Dataset2))
  })
  
  output$downloadEx2fold2 <- downloadHandler(
    
    filename <- function() {
      paste('Example ds', Sys.time(),'.csv', sep='')
    },
    content <- function(file) {
      dsfold2 <- data_input2fold2()
      write.csv(dsfold2, file, row.names = FALSE)
    }
  )
  
  super_PC2 <- reactive({
    input$goButton1
    
    validate(
      need(!is.null(data_input4()) & !is.null(data_input5()), label = "Data sets")
    )
    
    if(!is.null(data_input4()) & !is.null(data_input5()))
    {
      data3 <- data_input4()
      data4 <- data_input5()
      foldid <- data_input2fold2()
      
      if (input$foldid2 == 0) {
        cv.order = NULL
        sub = NULL
        withProgress(message = 'Iterations', value = 0, {
          
          sup <- isolate(superpccox(data3, data4, nstep = as.integer(input$cutoff2), prop = as.numeric(as.integer(input$split2)/100), nfold = as.integer(input$nfold1), cv.order = cv.order, sub=sub ))
          
        })
      } else if (input$foldid2 == 1) {
        cv.order = as.vector(foldid[, 2])
        sub = as.vector(foldid[, 3])
        withProgress(message = 'Iterations', value = 0, {
          
          sup <- isolate(superpccox(data3, data4, nstep = as.integer(input$cutoff2), prop = as.numeric(as.integer(input$split2)/100), nfold = as.integer(input$nfold1), cv.order = cv.order, sub=sub))
        })
      }
      
    }
    else
      return(NULL)
  })
  
  output$SuperPC2 <- DT::renderDataTable({
    input$goButton1
    validate(
      need(!is.null(data_input4()) & !is.null(data_input5()), label = "Data sets")
    )
    
    isolate(DT::datatable(super_PC2()[[3]], options = list(
      lengthMenu = list(c(5, 10, -1), c('5', '10', 'All')),
      pageLength = 10)))
  })
  
  output$predictplot2 <- renderPlot({
    input$goButton1
    
    if(!is.null(super_PC2())) {
    isolate(
      plot(super_PC2()[[2]], col=2:3, xlab="time", ylab="Prob survival"))
    }
  })
  
  
  output$ex_p2 <- renderPrint({
    input$goButton1
    
    if(!is.null(super_PC2())) {
    isolate(cat(paste("The p-value for the first Principal component is = ", round(super_PC2()[[1]],3), ".", sep = "")))
    }
  })
  
  output$downloadSuperPC2 <- downloadHandler(
    
    filename <- function() {
      paste('Super PC Results', Sys.time(),'.csv', sep='')
    },
    content <- function(file) {
      ds8 <- super_PC2()[[3]]
      write.csv(ds8, file, row.names = TRUE)
    }
  )
  
  output$downloadfoldid2 <- downloadHandler(
    
    filename <- function() {
      paste('Fold IDs', Sys.time(),'.csv', sep='')
    },
    content <- function(file) {
      dsfold <- data.frame(super_PC2()[[4]])
      colnames(dsfold) <- c('foldid', 'resample')
      write.csv(dsfold, file, row.names = TRUE)
    }
  )
  
  output$pv3 <- renderUI({
    input$goButton1
    hs1 <- paste("&emsp;")
    hs2 <- paste("Association between Continuous Predicted Principal Component with Time to Event Outcome")
    isolate(HTML(paste(h2(strong(hs2)), hs1, sep = '<br/>')))
  })
  
  
  output$pv4 <- renderUI({
    input$goButton1
    hs1 <- paste("&emsp;")
    hs2 <- paste("KM Plot for Discrete Predicted Principal Component (Cut by Median)")
    isolate(HTML(paste(hs1, h2(strong(hs2)), hs1, sep = '<br/>')))
  })
  
  
  output$title2 <- renderUI({  
    input$goButton1
    hs1 <- paste("&emsp;")
    hs2 <- paste("Important Features Selected")
    isolate(HTML(paste(hs1, h2(strong(hs2)), hs1, sep = '<br/>')))
  })
  
  data_input6 <- reactive({
    if(input$file6 == 'Example6'){
      d6 <- read.csv("data/file1.csv")
    }
    else if(input$file6 == 'load_my_own'){
      inFile <- input$file61
      if (is.null(inFile))
        return(NULL)
      else if(grepl(".xlsx", inFile[1])) { d6 = read.xlsx(as.character(inFile$datapath), colNames = TRUE, rowNames = F, as.is = T) }
      else if(grepl(".csv", inFile[1])) { d6 = read.csv(as.character(inFile$datapath), header = TRUE, sep = ",", stringsAsFactors = F, as.is = T, fill = T) }
      else if(grepl(".txt", inFile[1])) { d6 = read.table(as.character(inFile$datapath), header = TRUE, sep = "\t", stringsAsFactors = F, as.is = T, fill = T) }
    }
    else 
      return(NULL)
    # dim(data)
    Dataset6 <- data.frame(d6)
    return(as.data.frame(Dataset6))
  })
  
  data_input7 <- reactive({
    if(input$file7 == 'Example7'){
      d7 <- read.csv("data/file2.csv", stringsAsFactors = F)
    }
    else if(input$file7 == 'load_my_own'){
      inFile <- input$file71
      if (is.null(inFile))
        return(NULL)
      else if(grepl(".xlsx", inFile[1])) { d7 = read.xlsx(as.character(inFile$datapath), colNames = TRUE, rowNames = F, as.is = T) }
      else if(grepl(".csv", inFile[1])) { d7 = read.csv(as.character(inFile$datapath), header = TRUE, sep = ",", stringsAsFactors = F, as.is = T, fill = T) }
      else if(grepl(".txt", inFile[1])) { d7 = read.table(as.character(inFile$datapath), header = TRUE, sep = "\t", stringsAsFactors = F, as.is = T, fill = T) }
    }
    else 
      return(NULL)
    # dim(data)
    Dataset7 <- data.frame(d7)
    return(as.data.frame(Dataset7))
  })
  
  output$downloadEx5 <- downloadHandler(
    
    filename <- function() {
      paste('Example ds Super PC', Sys.time(),'.csv', sep='')
    },
    content <- function(file) {
      ds9 <- data_input6()
      write.csv(ds9, file, row.names = FALSE)
    }
  )
  
  output$downloadEx6 <- downloadHandler(
    
    filename <- function() {
      paste('Example ds Super PC', Sys.time(),'.csv', sep='')
    },
    content <- function(file) {
      ds10 <- data_input7()
      write.csv(ds10, file, row.names = FALSE)
    }
  )
  
  data_input2fold3 <- reactive({
    if(input$file22fold3 == 'Example2'){
      d2 <- read.csv("data/foldid2.csv", header =T, sep =",", stringsAsFactors = F)
    }
    else if(input$file22fold3 == 'load_my_own'){
      inFile <- input$file221fold3
      if (is.null(inFile))
        return(NULL)
      else if(grepl(".xlsx", inFile[1])) { d2 = read.xlsx(as.character(inFile$datapath), colNames = TRUE, rowNames = F, as.is = T) }
      else if(grepl(".csv", inFile[1])) { d2 = read.csv(as.character(inFile$datapath), header = TRUE, sep = ",", stringsAsFactors = F, as.is = T, fill = T) }
      else if(grepl(".txt", inFile[1])) { d2 = read.table(as.character(inFile$datapath), header = TRUE, sep = "\t", stringsAsFactors = F, as.is = T, fill = T) }
    }
    else 
      return(NULL)
    # dim(data)
    Dataset2 <- data.frame(d2)
    return(as.data.frame(Dataset2))
  })
  
  output$downloadEx2fold3 <- downloadHandler(
    
    filename <- function() {
      paste('Example ds', Sys.time(),'.csv', sep='')
    },
    content <- function(file) {
      dsfold2 <- data_input2fold3()
      write.csv(dsfold2, file, row.names = FALSE)
    }
  )
  
  super_PC3 <- reactive({
    input$goButton2
    
    validate(
      need(!is.null(data_input6()) & !is.null(data_input7()), label = "Data sets")
    )
    
    if(!is.null(data_input6()) & !is.null(data_input7()))
    {
      data5 <- data_input6()
      data6 <- data_input7()
      
      foldid <- data_input2fold3()
      
      if (input$foldid3 == 0) {
        cv.order = NULL
        sub = NULL
        withProgress(message = 'Iterations', value = 0, {
          isolate(sup <- superpccon(data5, data6, nstep = as.integer(input$cutoff3), prop = as.numeric(as.integer(input$split3)/100), nfold = as.integer(input$nfold2), cv.order = cv.order, sub=sub))
          
        })
      } else if (input$foldid3 == 1) {
        cv.order = as.vector(foldid[, 2])
        sub = as.vector(foldid[, 3])
        withProgress(message = 'Iterations', value = 0, {
          
          sup <- isolate(superpccon(data5, data6, nstep = as.integer(input$cutoff3), prop = as.numeric(as.integer(input$split3)/100), nfold = as.integer(input$nfold2), cv.order = cv.order, sub=sub))
        })
      }
      
    }
    else
      return(NULL)
  })
  
  output$SuperPC3 <- DT::renderDataTable({
    input$goButton2
    
    validate(
      need(!is.null(data_input6()) & !is.null(data_input7()), label = "Data sets")
    )
    
    isolate(DT::datatable(super_PC3()[[3]], options = list(
      lengthMenu = list(c(5, 10, -1), c('5', '10', 'All')),
      pageLength = 10)))
    
  })
  
  output$predictplot3 <- renderPlot({
    input$goButton2
    dat <- super_PC3()[[2]]
    
    if (input$Predicted2 == 1) {
      isolate(boxplot(dat$outcome~dat$pred.discrete, main = "Box plot of Predicted Principal Component between Observed Outcome"))
      
    } else if (input$Predicted2 == 0) {
      outcome = dat$outcome
      predicted = dat$pred.contiuous
      isolate(plot(outcome, predicted, main = "Scatter plot of Predicted Principal Component and Observed Outcome"))
    } 
  })
  
  output$ex_out3 <- renderPrint({
    input$goButton2
    dat <- super_PC3()[[2]]
 
    if (input$Predicted2 == 1) {
      isolate(pander(t.test(dat$outcome~dat$pred.discrete)))
      
    } else if (input$Predicted2 == 0) {
      outcome = dat$outcome
      predicted = dat$pred.contiuous
      isolate(pander(cor.test(outcome, predicted)))
    } 
  })
  
  output$ex_p3 <- renderPrint({
    input$goButton2
    
    if(!is.null(super_PC3())) {
      isolate(cat(paste("The p-value for the first Principal component is = ", round(super_PC3()[[1]],3), ".", sep = "")))
    } 
  })
  
  output$downloadSuperPC3 <- downloadHandler(
    
    filename <- function() {
      paste('Super PC Results', Sys.time(),'.csv', sep='')
    },
    content <- function(file) {
      ds11 <- super_PC3()[[3]]
      write.csv(ds11, file, row.names = TRUE)
    }
  )
  
  output$downloadfoldid3 <- downloadHandler(
    
    filename <- function() {
      paste('Fold IDs', Sys.time(),'.csv', sep='')
    },
    content <- function(file) {
      dsfold <- data.frame(super_PC3()[[4]])
      colnames(dsfold) <- c('foldid', 'resample')
      write.csv(dsfold, file, row.names = TRUE)
    }
  )
  
  output$pv5 <- renderUI({
    input$goButton2
    hs1 <- paste("&emsp;")
    hs2 <- paste("Association between Continuous Predicted Principal Component with Continuous Outcome")
    isolate(HTML(paste(h2(strong(hs2)), hs1, sep = '<br/>')))
  })
  
  
  output$pv6 <- renderUI({
    input$goButton2
    hs1 <- paste("&emsp;")
    hs2 <- paste("Plot and Tests for Predicted Principal Component")
    isolate(HTML(paste(hs1, h2(strong(hs2)), hs1, sep = '<br/>')))
  })
  
  
  output$title3 <- renderUI({
    input$goButton2
    hs1 <- paste("&emsp;")
    hs2 <- paste("Important Features Selected")
    isolate(HTML(paste(hs1, h2(strong(hs2)), hs1, sep = '<br/>')))
  })
  
  output$ReadMe1 <- renderUI({
    str0 <- paste("&emsp;")
    str12 <- paste("Background:")
    str11 <- paste("&emsp;&emsp; Currently, the Super PC method has been implemented in an R package 'superpc' for time-to-event outcome and a continuous outcome. 
                   However, it did not incorporate binary outcome in this R package. Furthermore, it is a programming-based tool which is not user-friendly for clinicians and biomedical researchers with limited programming exposure. 
                   To overcome the limitations, we are presenting GAC: Gene Association with Clinical, an interactive web-based application for gene association with different clinical outcomes of interest, developed based on R package 'shiny' and 'superpc'. 
                   GAC could perform a SuperPC analysis for three various types of outcome including time-to-event, continuous and binary. Meanwhile, the users could generate a forest plot to visualize the clinical association for a binary outcome with different genetic or clinical variables of interest simultaneously.")
    str3 <- paste("Supervised Principal Components Analysis (Super PC)")
    str4 <- paste("NOTE: This app provides a one stop shop to carry out clinical association with multiple genes at one time. You can have three different types of outcome, 
                  including binary, time to event and continuous outcomes.")
    str5 <- paste("&emsp;&emsp;  a)   Tab 2. This is for gene association with a time-to-event outcome of interest.")
    str6 <- paste("&emsp;&emsp;  b)   Tab 3. This is for gene association with a continous outcome of interest.")
    str7 <- paste("&emsp;&emsp;  c)   Tab 4. This is for gene association with a binary outcome of interest." )
    str9 <- paste("NOTE1: For all supervised principal component analysis, you will be able to upload data, choose number of iterations, number of folds, proportion to subset datasets. You can also choose to replicate the results with existing fold ids or not. To replicate, upload your previously saved fold ids.")
    str10 <- paste("NOTE2: For the results, you can find the association between the predicated principal component with a set of selected important genes through plot and summary statistics and analysis. 
                   You will also be able to view and download the selected important genes.")
    str1 <- paste("Forest Plot")
    str2 <- paste("In the fifth Tab, you are able to upload your associations with a binary outcome to generate a forest plot.")
    HTML(paste(h5(strong(str12)), str0, str11, str0, h5(strong(str3)), str0, str4,str0,  str5, str0, str6,str0,  str7, str0, strong(str9), str0,strong((str10)),str0,str0, str0, str0, h5(strong(str1)), str0, str2,  sep = '<br/>'))
  })
  
}

 