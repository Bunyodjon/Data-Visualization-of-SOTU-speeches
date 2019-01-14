---
title: "About"
date: "November 28, 2018"
output: html_document
---

## **State of the Union Address and Sentiment Analysis**

### **Author: Bunyodjon Tusmatov**

This Shiny app is for visualizating State of the Union(SOTU) addresses of last three president of America. The first tab of the app allows users to see differences between presedential speeches using comparison clouds. The comparison cloud compares the `relative frequency` with which a term was used in two or more documents. It plots the difference between the word usage in the document (Kopp, 2017). 

The second tab allows users to see association of SOTU speeches with the NRC lexicon which is ten basic emotions (anger, fear, anticipation, trust, surprise, sadness, joy, disgust, negative and positive). The plot shows how many emotion words used in each speech and allows users to compare different speeches. If the same president speech selected more than 1, it averages those numbers between different years and plots them.  

Third tab allows users to view  sentiment score of speeches from the beginning till the end of a speech, and compre how sentiment score differs between speeches and from sentence to sentence. The large average lines shows moving average for ten sentences. The reason for including this is that sentiment score is very volatite between words and average of ten sentences gives a better picture. I used ten because ten sentences makes up two paragraphs. The tab uses afinn lexicon by Finn Årup Nielsen which is the list of English terms manually rated between -5(negative) and 5(positive).

### **References:**

1. The American Presidency Project (2018). University of California Santa Barbara.  Retrieved from https://www.presidency.ucsb.edu/documents/presidential-documents-archive-guidebook/annual-messages-congress-the-state-the-union

2. Creating a Word Cloud in R (2017). Brandon Kopp. Retrieved from https://rpubs.com/brandonkopp/creating-word-clouds-in-r 


3. Interactive visualizations. (2018). Shiny RStudio Gallery website. Retrieved from https://shiny.rstudio.com/gallery/superzip-example.html 

