# INTRODUCTION – 

The day-by-day upsurge in the volume of unsolicited marketing emails (called spam) has generated a need for powerful anti-spam email classifier. The classifier should be able to correctly identify spam emails and non-spam (a.k.a ham) emails. In this project, Bayes theorem is used to build a spam classifier. 


# CONCEPTS –
## Bayes Theorem – 
Bayes theorem describes the probability of an event, based on prior knowledge of conditions that might be related to the event.
The formula for Bayes theorem is - 

P(A ┤|  B)=□((P(B ┤|  A).P(A))/(P(B)))
where A and B are events and P(B)‡0
	P(A ┤|  B) is a conditional probability: the likelihood of event A occurring given that B  is true
	P(B ┤|  A) is also a conditional probability: the likelihood of event B  occurring given that A is true
	P(A) and P(B) are the probabilities of observing A and B respectively; they are known as the marginal probability.
	A and B must be different events

So, for example, given that the email has the word "free" in it, what is the probability of this email being spam? Using Bayes theorem, we can now calculate the same probability as -
P(Spam ┤|  Free)=□((P(Free ┤|  Spam).P(Spam))/(P(Free)))

Where P(Spam ┤|  Free) is the probability of a mail being Spam given that it contains the word “Free” in it and P(Free ┤|  Spam) is the probability of the word “Free” being present in a spam email. We calculate the probability for many such words and assuming that the occurrence of these words is independent, we calculate the joint probability by multiplying all the individual probabilities to classify whether the email is spam or ham.


## Word Cloud – 
Word cloud is a simple visualization technique where a group of words in a text are represented with the size of each word indicating its relative frequency.


## Model Testing Metrics – 

	Accuracy –  the fraction of the total predictions that the model got right 

	Precision – the ratio of correctly predicted spam messages to the total number of times the model predicted that an email was spam 
Formula = □((True Positives)/((True Positives + False Positives) ))

	Recall – the ratio between the correctly identified spam emails and all the spam emails that were present
Formula = □((True Positives)/((True Positives + False Negatives)))

	F-score – 
Formula = 2*  (Precision * Recall)/((Precision + Recall))


## Bag of words Approach – 

The Bag of Words approach is used for classifying documents. Each word is looked in isolation and the frequency of each word becomes a feature in the machine learning model. The fact that each word is looked at in isolation is why this model is called Naive. Each word is treated separately. Grammar and sarcasm are ignored. The city name “New York” is treated as two separate words, New and York. The context is lost with the Bag of Words approach. The dependencies between the words are ignored. The assumption here is that the words are independent, like words in a bag.


# DATA SOURCE – 

The source of the data for this project is the  Spam Assassin public corpus. All the e-mail data used in the project comes from an open source anti-spam platform called SpamAssassin. Spam Assassin has a huge set of spam and ham emails that they've made available to the public to do things like train a spam classifier.
Link to the Source data files - https://github.com/shobha-bhagwat/Machine-Learning/blob/master/Spam%20Filter/SpamData.zip 

It contains 1898 spam emails and 3901 ham emails. 


# DATA PREPARATION –

The data preparation steps followed were – 
## Converting to lower case
	Converting all email text to lower case

## Tokenizing
	Splitting up the sentences in the email into individual words. The method word_tokenize from nltk.tokenize package is used here for tokenizing

## Removing stop words
	Stop words are the words which don’t change the meaning of a sentence but are important for grammar (e.g. “the”, “a”, “at”, “which”). The stop words are excluded from the message text and that's because the Naive Bayes Classifier will be looking at individual words in isolation (bag of words approach). The meaning is actually lost on the algorithm and this is why the stop words are filtered out using a list of 179 common English  stop words.

## Word Stemming
	Stemming is the process of reducing words to their base/root form. E.g. the words "fishing", "fished", "fisher" and "fishlike" are all reduced by the stemmer to the word "fish". Sometimes stemming might result into a non-proper word. E.g. the words "argue", "argued", "argues" and "arguing" are all stemmed to the word "argu". The Porter Stemmer is used in this project.

## Removing punctuation
	Since the classifier ignores punctuation, those are removed from the stemmed text.

## Stripping out HTML Tags
	Since the classifier requires only individual words, we remove the punctuation using “Beautiful Soup” Python module.

