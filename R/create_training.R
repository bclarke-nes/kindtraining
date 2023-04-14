#' This package will create a function called create_training()
#'
#' It's callback is at: inst/rstudio/templates/project/create_training.dcf
#'
#' @export
create_training <-
  function(path, ...) {
    # Create the project path given the name chosen by the user:
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
    # Change the working directory to the recently created folder:
    setwd(file.path(getwd(), path))
    # Collect the list of inputs in a list to be called later:
    dots <- list(...)

    # helper function to shuffle the files in the package into the correct locations
    subpath <- function(from, to) {
      fs::dir_copy(
        path = paste0(system.file(package = "kindtraining"), from),
        new_path = to,
        overwrite = TRUE
      )
    }

    # do the fixed folders first
    dir.create("archive")
    dir.create("data")
    dir.create("src")
    dir.create("src/images")
    dir.create("src/R")

    # Check .gitignore argument
    if (dots[["createGitignore"]]) {
      git_ignores <-
        c(
          '.Rhistory',
          '.Rapp.history',
          '.RData',
          '.Ruserdata',
          '.Rproj.user/',
          '.Renviron'
        )
      writeLines(paste(git_ignores, sep = '\n'), '.gitignore')
    }

    # Check training type
    if (dots[["type"]] == "Rmarkdown") {
      dir.create("rmd", recursive = TRUE, showWarnings = FALSE)
    } else if (dots[["type"]] == "Quarto") {
      dir.create("qmd", recursive = TRUE, showWarnings = FALSE)
    } else if (dots[["type"]] == "Reveal.js slides") {
      dir.create("milestones",
                 recursive = TRUE,
                 showWarnings = FALSE)
      dir.create("src/session_outlines",
                 recursive = TRUE,
                 showWarnings = FALSE)
      dir.create("src/text_sections",
                 recursive = TRUE,
                 showWarnings = FALSE)
      dir.create("slides", recursive = TRUE, showWarnings = FALSE)
    }

    if (dots[["type"]] == "Rmarkdown") {
      for (i in 1:dots[["number"]]) {
        rmd_contents <- c(
          '---',
          paste0(
            'title: "![](../src/images/KLN_banner_v05_125.png) ',
            dots[["title"]],
            '"'
          ),
          paste0('subtitle: "session ', i, '"'),
          'author: "Brendan Clarke, NHS Education for Scotland, [brendan.clarke2@nhs.scot](mailto:brendan.clarke2@nhs.scot)"',
          paste0('date: "', Sys.Date(), '"'),
          'output:',
          '  html_document:',
          '    toc: no',
          '    toc_depth: 2',
          '    number_sections: no',
          '    toc_float:',
          '      collapsed: no',
          'always_allow_html: yes',
          '---',
          '',
          '```{r pre-setup, message=FALSE, warning=FALSE, echo=F}',
          'knitr::opts_chunk$set(echo = TRUE, warning = F, message = F)',
          'install.packages(setdiff("pacman", rownames(installed.packages())))',
          '',
          'library(pacman)',
          'p_load(tidyverse)',
          '```',
          '',
          '# {.tabset}',
          '## Introduction'
        )

        readr::write_lines(rmd_contents,
                           paste0("rmd//session_", i, ".rmd"))
      }
    }

    if (dots[["type"]] == "Quarto") {
      for (i in 1:dots[["number"]]) {
        qmd_contents <- c(
          '---',
          paste0(
            'title: "![](../src/images/KLN_banner_v05_125.png) ',
            dots[["title"]],
            '"'
          ),
          paste0('subtitle: "session ', i, '"'),
          'author: "Brendan Clarke, NHS Education for Scotland, [brendan.clarke2@nhs.scot](mailto:brendan.clarke2@nhs.scot)"',
          paste0('date: "', Sys.Date(), '"'),
          '---',
          '',
          '```{r}',
          '#| echo: false',
          '#| warning: false',
          'library(pacman)',
          'p_load(tidyverse)',
          'knitr::opts_chunk$set(echo = T, warning = F, message = F, results = "asis", fig.width = 7, fig.height = 4)',
          '```',
          '',
          '::: {.panel-tabset}',
          '## Introduction',
          ':::'
        )

        readr::write_lines(qmd_contents,
                           paste0("qmd//session_", i, ".qmd"))
      }
    }


    readr::write_lines(paste0("Welcome to ", dots[["title"]]), paste0("readme.md"))

    subpath("/logo", "src/images")

    if (dots[["type"]] == "Reveal.js slides") {
      settings_file <- c(
        'milestone_output_path <- "milestones"',
        'milestone_delim <- "^#.*ms[ 0-9]*[ -]+"',
        'milestone_delim_text <- "\\\\(MILESTONE "',
        'milestone_delim_quarto <- "## Milestone "',
        'slide_output_path <- "slides"',
        paste0('course_name_computer <- "', path, '_"'),
        paste0('course_name_human <- "', dots[["title"]], '"'),
        'author <- "Brendan Clarke"',
        'logo <- "..//src//images//KLN_banner_v05_125.png"',
        'css_path <- "..//src//images//logo.css"',
        'outline_input_path <- "src//session_outlines"',
        'text_input_path <- "src//text_sections"'
      )

      readr::write_lines(settings_file, paste0("src/R/settings.R")) # will need this inside the reveal.js conditional.

      for (i in 1:dots[["number"]]) {
        text_contents <- c(
          '## About this course',
          '',
          '+ Social',
          '',
          '::: {.callout-note}',
          'Cameras on as much as possible, please',
          ':::',
          '',
          '+ Collaborative, particularly for troubleshooting',
          '',
          paste0('## Session ', formatC(
            i, width = 2, flag = 0
          ), ' outline'),
          '1.',
          '',
          '## Session milestones',
          '1. ',
          '',
          '## Helpful resources',
          '+ ',
          '',
          '## Set-up'
        )

        readr::write_lines(
          text_contents,
          paste0(
            "src//text_sections//",
            path,
            "_session_",
            formatC(i, width = 2, flag = 0),
            ".md"
          )
        )

        session_contents <- c(
          '## ms 1 ----',
          'install.packages(setdiff("pacman", rownames(installed.packages())))',
          'library(pacman)',
          'p_load(tidyverse)'
        )

        readr::write_lines(
          session_contents,
          paste0(
            "src//session_outlines//",
            path,
            "_session_",
            formatC(i, width = 2, flag = 0),
            ".R"
          )
        )

        main_file <- c(
          'library(pacman)',
          'p_load(tidyverse, KINDR)',
          'source("src/R/settings.R")',
          '',
          'make_qmd(1)'
        )

        readr::write_lines(main_file, "main_file.R")
      }
    }
  }
