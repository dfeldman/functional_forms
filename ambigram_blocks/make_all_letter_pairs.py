#!/usr/bin/python

def clean(letter):
    if letter=="*": return "star"
    if letter=="|": return "blank"
    if letter=="@": return "at"
    if letter=="$": return "dollar"
    if letter=="#": return "hash"
    if letter=="!": return "excl"
    if letter=="?": return "quest"
    if letter=="/": return "slash"
    return letter

def fname(letter1, letter2):
    letter1 = clean(letter1)
    letter2 = clean(letter2)
    return "scad_files/%s_%s.scad" % (letter1, letter2) 

def genfile(letter1, letter2):
    text=open("ambigram_block.scad").read()
    text=text.replace("LETTER1", letter1)
    text=text.replace("LETTER2", letter2)
    return text

def make_characters():
    letters=range(ord("A"), ord("Z")+1)
    letters.append(ord("*"))
    letters.append(ord("/"))
    letters.append(ord("|"))
    for letter1 in range(len(letters)/2+1):
        for letter2 in range(len(letters)):
            with open(fname(chr(letters[letter1]), chr(letters[letter2])), "w") as f:
                f.write(genfile(chr(letters[letter1]), chr(letters[letter2])))

if __name__=="__main__":
    make_characters()
