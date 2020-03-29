1.	INTRODUCTION – 
The objective of this project is to do sentiment analysis of the different definitions in the online Urban Dictionary. Since the urban dictionary uses colloquial language, by analyzing the feeling of different definitions we will be able to make better sense of the colloquial language used by people today on social media or on various feedback platforms on web. The more accurate the sentiment prediction of customer feedbacks, the better it will be for marketing teams of respective products and services.

2.	CONCEPTS –
1.	Sentiment Analysis – 
Sentiment Analysis is contextual mining of text to identify and extract relevant information from the text. The primary usage of sentiment analysis is by businesses to track the customer sentiment for their brand/products/services on online feedback platforms and forums, thereby aiding their marketing efforts. Sentiment Analysis systems gauge the underlying sentiment of the text by assigning weighted sentiment scores to the entities, topics, themes, categories in the text. Sentiment analysis is also one of the building blocks of text classifier which is widely used in online marketplace like Amazon to make product recommendation to users based on their purchase history. Sentiment Analyzer mines the rich source of user feedback/comment on these online marketplaces to help understand user requirements and preferences for the recommender engines.

2.	Word Cloud – 
Word cloud is a simple visualization technique where a group of words in a text are represented with the size of each word indicating its relative frequency.


3.	METHODOLOGY – 
Data sources – 
Urban Dictionary is a crowdsourced online dictionary of popular slang words and phrases. It uses colloquial language and consists of following fields – 
•	word - the slang term added to urban dictionary
•	definition - the definition of said term
•	author - the user account who contributed the term
•	tags - a list of the hashtags used
•	up - upvotes
•	down - downvotes
•	date - the date the term was added to Urban Dictionary

The source file is attached here. It consists of 4272 observations.

AFINN text file has also been used in the project. AFINN is a list of English words rated for valence with an integer between minus five (negative) and plus five (positive). The words have been manually labeled by Finn Årup Nielsen in 2009-2011. The AFINN files is attached below. It has the word and its corresponding sentiment score.

The steps followed in the analysis are – 
1.	Reading the urban_dictionary.csv file and removing unnecessary fields.
2.	Identifying the top 10 authors with largest contribution to the urban dictionary
3.	Identifying words with high frequencies
4.	General average of positive and negative votes to gauge the dataset
5.	Most positive (“Cumberbitch”) and negative word (“Donald Trump”) in the dictionary based on the upvotes and downvotes.
6.	Calculating sentiment score for the definition of each word in the dictionary to bet identify the sentiment associated with that word. This is achieved by splitting the definitions into words and then assigning sentiment score to those words by looking up their score from the AFINN.txt file. Finally adding the scores of individual words in the definition to get overall sentiment score for the entire definition.
7.	Identifying top 10 positive and negative words and forming their word clouds
8.	Identifying words with large difference between their up and down votes i.e. highly popular or highly unpopular words
9.	Pie- charts depicting split of count of words with positive sentiment score vs. count of words with negative sentiment scores and split of count of words with positive likes (i.e. more upvotes) and dislikes.

4.	RESULTS – 

Since a lot of words are missing in the AFINN file, the accuracy of the analysis would be reduced. Also, since it is colloquial language, that might be the reason for more negative score. 

5.	DISCUSSION – 

Majority of the user feedbacks on online forums or social media are colloquial. The technique used in this project will form the basis of sentiment analysis of such data. The only drawback here is the AFINN text will not be able to identify sarcasm and hence those may result is opposite sentiment detection.


6.	CONCLUSION – 

The traditional sentiment analysis has been modified slightly in this project to better work with colloquial language usually found on internet these days. This can be used as building block in the text classifiers or recommender systems for sentiment analysis of user feedback.

