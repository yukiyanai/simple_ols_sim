## ui.R for simple_ols_sim
##
## 2021-06-06 Yuki Yanai

library(shiny)
library(ggplot2)

shinyUI(fluidPage(
    
    #theme = bslib::bs_theme(bootswatch = "sandstone"),
    
    titlePanel("単回帰のシミュレーション"),
    
    fluidRow(
        column(1),
        column(2,
               br(),
               img(src = "yanai_lab_logo.png", height = 120),
               br(),
               br()),
        column(9)
    ),

    sidebarLayout(
        sidebarPanel(
            numericInput("alpha", "母回帰の切片",
                        value = 0,
                        min = -2,
                        max = 2,
                        step = 0.1),
            numericInput("beta", "母回帰の傾き",
                        value = 0.5,
                        min = -5,
                        max = 5,
                        step = 0.1),
            numericInput("sigma", "誤差項の標準偏差",
                        val = 1,
                        min = 0.1,
                        max = 5,
                        step = 0.1),
            sliderInput("xrange", "Xの範囲",
                        value = c(-2, 2),
                        min = -5,
                        max = 5),
            actionButton("pop", "母集団を生成！"),
            br(),
            br(),
            numericInput("N", "標本サイズ",
                         value = 10,
                         min = 1, 
                         max = 100),
            actionButton("sample", "標本抽出！")
        ),

        mainPanel(
            plotOutput("plot",
                       brush = "plot_brush",
                       dblclick = "plot_reset"),
            tableOutput("estimate")
        )
    )
))
