# Exclusive co-occurrences

This collection of scripts (using Fiji and Python through the workflow) enables to segment cells and spots and count exclusive co-occurrences between two channels of spots.

A co-occurrence is counted whenever two objects from two different channels are closer than a certain threshold distance.

The prefix in the file's name indicates the order in which the scripts must be ran.

At the begining, all images have to be placed in a same folder.

The classifiers for the spots must be named after the dye's name: "Dye-last.classifier" (ex: "RFP-last.classifier" or "GFP-last.classifier").