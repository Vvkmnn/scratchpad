/* LINK https://news.ycombinator.com/item?id=21537314  */
/* LINK https://blog.floydhub.com/naive-bayes-for-machine-learning/ */
/* If you prefer code over text: */

  float 
  bayes(float prior, BAYES_TEST * test, int result) {
    if (result) {
      return prior* test->true_positive / (prior * test->true_positive + (1-prior) * test->false_positive);
    }
    return (prior * (1-test->true_positive)) / ( (prior * (1-test->true_positive)) + (1-prior) * (1-test->false_positive));
  }

/* This is basically the core of anything that uses 'Naive Bayes', that's really all there is to it. Note that Naive Bayes tends to 'clamp' to 0 or 1 after enough evidence has been processed, you're not going to end up with a value somewhere in the middle in the vast majority of cases. Also, when it doesn't work there won't be any hint that you are mis-classifying, because of the above mentioned property the posterior returned is not going to help much in terms of determining your confidence level. Note that if you evaluate a lot of evidence sequentially and the criteria are not 'independent' then you won't get good results. Independent criteria can vary independently from each other, so for instance if you base three of your criteria on someone's IP address you won't get much mileage out of the second and third and you're going to over-represent that factor in the weighing of the evidence. */
/* Still, it is super easy to get up and running, will work with remarkably little data to train with (determine those false positive and true positive ratios) and runs very fast during classification, it also requires very little in terms of hardware (no GPU or anything like that). */

/* Yes, you can improve on this, but it isn't always worth the effort or the resources, I've built more than one revenue generating tool with this. */
