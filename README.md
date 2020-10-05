# Power analysis for NLP


This repo exists to accompany the paper **With Little Power Comes Great Responsibility**, by [Dallas Card](https://web.stanford.edu/~dcard/), [Peter Henderson](https://www.peterhenderson.co/), [Urvashi Khandelwal](https://nlp.stanford.edu/~urvashik/), [Robin Jia](https://robinjia.github.io/), [Kyle Mahowald](https://mahowak.github.io/), and [Dan Jurafsky](https://web.stanford.edu/~jurafsky/), to be published at EMNLP 2020.

Here you can find the raw anntoations described in the paper, code to reproduce most of the figures, and notebooks which can be adapted for running your own power analyses, including online interactive notebooks.


### Online notebooks

To accompany the paper, we have provided some online notebooks on Google Colaboratory which can be used as starter code for running simple power analyses. These can be copied and run in an interactive manner.

At the moments, we have notebooks for the following scenarios:

- [Power analsis for accuracy comparisons](https://colab.research.google.com/drive/1anaS-9ElouZhUgCAYQt8jy8qBiaXnnK1?usp=sharing)
- [Power analysis BLEU score comparisons](https://colab.research.google.com/drive/13S--riSmpGXB3Vm52yFKKZrx7z73suc8?usp=sharing)
- [Fitting a mixed-effects model](https://colab.research.google.com/drive/1SluI2HrDN6b06_52bMMJJCOvQ1A63MIX?usp=sharing) to one of the public human evaluation datasets used in the paper (see below for additional datasets)
- [Power analysis for Likert scale human evaluation data](https://colab.research.google.com/drive/11ZV8KxKwZ-2vtYzZnHCtkew7byTWJFPs?usp=sharing) using mixed effects models

Note that some of these Google colaboratory notebooks will require you to grant access such that they can read from your Google Drive. To do so, run the cell that contains `drive.mount('/content/drive')`, click the link to get an access key, and then paste it into the cell.

These notebooks are also included locally in `notebooks_for_power_calculations` -- the first two as ipython notebooks, and the latter two as R scripts. Note that these are suggested as a starting point, but will require some consideration to apply to other cases.

### Local Requirements

All code in this repo is presented in terms of notebooks and scripts in python and R. You can install the required python components using the `requirements.txt` file. Alternatively, if using conda, you can create an environment with the required packages, and then load a notebook using:

```
conda create -n nlp-power python=3
conda activate nlp-power
conda install numpy scipy matplotlib ipython notebook tqdm pandas statsmodels seaborn
ipython notebook
```

### Comparing Models on Accuracy

- Starter code for running power analyses for comparing classifiers (in terms of accuracy, using hypothesized values for $\Delta_{acc}$ and $P_a$) is provided in `notebooks_for_power_calculations/accuracy.ipynb` (also available as an [online interactive notebook](https://colab.research.google.com/drive/1anaS-9ElouZhUgCAYQt8jy8qBiaXnnK1?usp=sharing)).
- Code to reproduce the related figrues (3, 7, and 8) is provided in `code_for_figures`.


### GLUE and SQuAD 2.0 analyses

- Code and data for analyzing the reported gains extracted from  papers (and the SQuAD 2.0 leaderboard) have been included. To run this online, it is first necessary to upload the two files in `data/GLUE/` to your Google Drive, and making a copy of this [online notebook](https://colab.research.google.com/drive/1ZgxUghqEsRyn22llH9AhmS_tLDfqQkOM?usp=sharing) (also included in this repo at `analyses/GLUE/Analyze_reported_results.ipynb`).
- Code for predicting overlap (used in estimating minimum detectable effec sizes is also included at `analyses/GLUE/Predict_Overlap_From_Glue.ipynb`, but cannot be run, as it depends on test set predictions on the GLUE benchmark which cannot be shared.


### Additional SQuAD v2.0 analyses

- Pairwise model results for SQuAD 2.0 on validation data is shared here. `data/SQuAD2/models.tsv` contains the models that had been submitted up to the time of writing (dev and test EM) `data/pairs_dev.tsv` contains pairwise validation results (difference in number correct and number of disagreements).
- Code for the analysis reported in Appendix D is included in `analyses/SQuAD2/Explore_squad_data.ipynb` but cannot be run, as it depends on pairwise results on test data data, which cannot be shared.



### Machine Translation

- Code for computing power on BLUE scores (using hypothesized values for $b_0$ and $\Delta_B$ is provided in `notebooks_for_power_calculations/BLEU.ipynb` (also available as an [online interactive notebook](https://colab.research.google.com/drive/13S--riSmpGXB3Vm52yFKKZrx7z73suc8?usp=sharing)).
- Code for estimating the Laplace-Delta mixture parameters from data is provided in `code_for_figures/Figure 15 (and 16).ipynb`


### Human Evaluation

There are several components to the human evaluation materals:

- The notebooks in `data_import` can be used to download and preprocess the publicly-available human evaluation datasets used in this paper. This is a necessary first step before running most of the R scripts below.
- Code for fitting mixed effects models to these datasets is included in `notebooks_for_power_calculations/estimate_parameters_from_datasets.R`
- One combined example (loading the data and fitting a model) is included as an [online notebook](https://colab.research.google.com/drive/1SluI2HrDN6b06_52bMMJJCOvQ1A63MIX?usp=sharing)
- The code we have used for power simulations is provided as `notebooks_for_power_calculations/power_sim.R`, and is also provided as an [online notebook](https://colab.research.google.com/drive/11ZV8KxKwZ-2vtYzZnHCtkew7byTWJFPs?usp=sharing)
- Finally, the meta-analysis of EMNLP 2019 results is provided in `analyses/human_eval/meta_analysis_submit.R`, with code for Figures 5 and 6 provided in the `code_for_figures` directory.


### References

TO BE ADDED

