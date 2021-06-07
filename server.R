## server.R for simple_ols_sim
##
## 2021-06-06 Yuki Yanai

pacman::p_load(shiny,
               tidyverse,
               broom)
if (.Platform$OS.type == "windows") { 
    if (require(fontregisterer)) {
        my_font <- "Yu Gothic"
    } else {
        my_font <- "Japan1"
    }
} else if (capabilities("aqua")) {
    my_font <- "HiraginoSans-W3"
} else {
    my_font <- "IPAexGothic"
}
theme_set(theme_gray(base_size   = 9,
                     base_family = my_font))

pop_size <- 200

shinyServer(function(input, output) {

    output$plot <- renderPlot({
        
        pop_df <- eventReactive(input$pop, {
            x <- runif(pop_size, min = -2, max = 2)
            y <- rnorm(pop_size, 
                       mean = input$alpha + input$beta * x, 
                       sd = input$sigma)
            tibble(x = x, y = y)
        })

        selected <- reactiveVal(rep(FALSE, pop_size))
        
        observeEvent(input$plot_brush, {
            brushed <- brushedPoints(pop_df(), 
                                     input$plot_brush, 
                                     allRows = TRUE)$selected_
            selected(brushed | selected())
        })
        
        observeEvent(input$plot_reset, {
            selected(rep(FALSE, pop_size))
        })
        
        observeEvent(input$pop, {
            selected(rep(FALSE, pop_size))
        })
        
        observeEvent(input$sample, {
            selected(sample(c(rep(TRUE, input$N), 
                              rep(FALSE, pop_size - input$N))))
        })
        
        pop_reg <- eventReactive(input$pop, {
            geom_abline(intercept = input$alpha,
                        slope = input$beta,
                        color = "royalblue")
        })
        
        output$plot <- renderPlot({
            myd <- pop_df() %>% 
                mutate(sel = selected())
            myd_sample <- myd %>% 
                filter(sel)
            ggplot(myd, aes(x = x, y = y)) +
                pop_reg() +
                geom_point(aes(color = sel)) +
                scale_color_brewer(palette = "Set1",
                                   limits = c("TRUE", "FALSE"),
                                   name = "標本") +
                geom_smooth(data = myd_sample,
                            method = "lm",
                            se = FALSE,
                            color = "red")
        }, res = 96)
        
        output$estimate <- renderTable({
            req(input$sample)
            if (sum(selected()) == 0) {
                print("標本が抽出されていません。")
            } else {
                myd_sample <- pop_df() %>% 
                    mutate(sel = selected()) %>% 
                    filter(sel)
                fit <- lm(y ~ x, data = myd_sample)
                tidy(fit, conf.int = TRUE) %>% 
                    rename(変数 = term,
                           推定値 = estimate,
                           標準誤差 = std.error,
                           t値 = statistic,
                           p値 = p.value,
                           `95%信頼区間の下限値` = conf.low,
                           `95%信頼区間の上限値` = conf.high)
            }
        })
    })

})
