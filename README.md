# OSU-automapping

Steps:
1.Using getosudatas.m to obtain training samples for the neural newtork
2.Train the network (Now I use the command 'nnstart' in matlab, which will genrate a function: MyNeuralNetworkFunction.m)
3.Choosing a song file, using NNmapping.m to generate a structure 'tp',which contains the information of beatmap.
4.Create an .osu file with tp and createOsuFile.m
