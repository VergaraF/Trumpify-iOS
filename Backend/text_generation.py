from __future__ import print_function
from keras.models import Sequential
from keras.layers import Dense, Activation, Dropout
from keras.layers import LSTM
from keras.optimizers import RMSprop
from keras.utils.data_utils import get_file
import numpy as np
import random
import sys

trump_LSTM_weigth_file = 'weights/trump_LSTM_weights_2_4.h5'

def sample(preds, temperature):
    # helper function to sample an index from a probability array
    preds = np.asarray(preds).astype('float64')
    preds = np.log(preds) / temperature
    exp_preds = np.exp(preds)
    preds = exp_preds / np.sum(exp_preds)
    probas = np.random.multinomial(1, preds, 1)
    return np.argmax(probas)

def acceptRequest(topic):
    text = open('train_data/trump_data_set.txt').read().lower()
    print('corpus length:', len(text))
    chars = sorted(list(set(text)))
    print('total chars:', len(chars))
    char_indices = dict((c, i) for i, c in enumerate(chars))
    indices_char = dict((i, c) for i, c in enumerate(chars))

    maxlen = 40
    step = 3
    sentences = []
    next_chars = []

    for i in range(0, len(text) - maxlen, step):
        sentences.append(text[i: i + maxlen])
        next_chars.append(text[i + maxlen])
    print('nb sequences:', len(sentences))

    print("Building model")
    model = Sequential()
    model.add(LSTM(128, input_shape=(maxlen, len(chars))))
    model.add(Dense(len(chars)))
    model.add(Activation('softmax'))
    optimizer = RMSprop(lr=0.001, rho=0.9, epsilon=1e-6)
    model.compile(loss='categorical_crossentropy', optimizer=optimizer)
    model.load_weights(trump_LSTM_weigth_file)
    print("Model complete")

    sentence = str(topic).lower()

    if len(sentence) < 40:
        get_diff = 40 - len(sentence)
        while get_diff > 0:
            sentence = ' ' + sentence
            get_diff -= 1

    generated = ''
    generated += sentence
    print('Generating with seed: "' + sentence + '"')
    sys.stdout.write(generated)

    for i in range(190):
        x = np.zeros((1, len(sentence), len(chars)))
        for t, char in enumerate(sentence):
            x[0, t, char_indices[char]] = 1.

        preds = model.predict(x, verbose=0)[0]
        next_index = sample(preds, 0.01)
        next_char = indices_char[next_index]

        generated += next_char
        sentence = sentence[1:] + next_char

    print(generated)
    return generated




