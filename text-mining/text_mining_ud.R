library(tm)
library(textstem)
library(qdap)
library(SnowballC)
library(lsa)

txt=read.csv(file="urban_dictionary.csv",header=TRUE)

str(txt)

########### Removing unnecessary fields
txt$tags=NULL
txt$date =NULL

########### Authors with high contribution to the dictionary
df_author = as.data.frame(table(txt$author))
df_author <-df_author[order(-df_author$Freq),]
head(df_author)


########### Words with large frequency
df_word = as.data.frame(table(txt$word))
df_word <-df_word[order(-df_word$Freq),]
head(df_word)

########### Average of positive and negative votes
positive_vote_avg = mean(txt$up)
negative_vote_avg = mean(txt$down)

########### Most positive and negative word based on up and down votes
pos_max=txt[which.max(txt$up),]
pos_word = pos_max$word

neg_max=txt[which.max(txt$down),]
neg_word=neg_max$word

############ Calculating sentiment score for each word definition
afinn = read.table('AFINN-111.txt', sep="\t", col.names=c("word", "score"))
head(afinn)

txt$score=0

scores=list()
count=0


for (d in txt$definition)           ### for each definition, split the sentence into words and calculate total score of the definition by adding individual score of the words found in AFINN
{ 
  df1 = strsplit(as.character(d)," ")
  score=0
  count = count+1
  #scores[count]=score
  for (w in df1)
  {
    for (j in w){ 
      k=afinn$score[afinn$word==j]
      if (length(k)>0)
      {
        score = score +k
        #cat("Score: ",score)
      }
    }
  }
  if (length(score)==0){
    score = 0 }
  scores[count]=score
  txt$score[txt$definition==d]=score
}

############### Most positive and negative sentiment definitions
neg_txt= head(txt[order(txt$score),])
neg_words=neg_txt$word

pos_txt= head(txt[order(-txt$score),])
pos_words=pos_txt$word


################# Word clouds for list of positive and negative sentiment words
word_network_plot(pos_words, 
                  wordcloud = TRUE,  proportional = TRUE,
                  network.plot = TRUE, cloud.colors = c("gray85", "darkred"))



word_network_plot(neg_words, 
                  wordcloud = TRUE,  proportional = TRUE,
                  network.plot = TRUE, cloud.colors = c("gray85", "darkred"))

				  
############### Words with large difference between their up and down votes i.e. highly popular or highly unpopular words
txt$diff = txt$up - txt$down

pos_diff= head(txt[order(-txt$diff),])
pos_diff_words=pos_diff$word


neg_diff= head(txt[order(txt$diff),])
neg_diff_words=neg_diff$word

txt$positive_likes = txt$up > txt$down
head(txt$positive_likes)


################## Pie-charts
df2 = as.data.frame(table(txt$positive_likes))
pct <- round(df2$Freq/sum(df2$Freq)*100)
lbls <- paste(df2$Var1, pct) # add percents to labels
lbls <- paste(lbls,"%",sep="") # add % to labels

pie(df2$Freq, labels = lbls, col=rainbow(length(df2$Freq)), main = "Positive words vs negative words split")

txt$positive_feeling = txt$score > 0
head(txt$positive_feeling)

df3 = as.data.frame(table(txt$positive_feeling))
pct <- round(df3$Freq/sum(df3$Freq)*100)
lbls <- paste(df3$Var1, pct) # add percents to labels
lbls <- paste(lbls,"%",sep="") # add % to labels

pie(df3$Freq, labels = lbls, col=rainbow(length(df3$Freq)), main = "Positive score vs negative score split")
