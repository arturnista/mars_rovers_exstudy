
# Mars rovers problem  

The problem description can be found at:  
https://github.com/GetAmbush/code-challenge/blob/master/challenge2.md  

This respository is an attempt to solve the problem.  

## Using
The most common use case is passing a string to `Mars.execute/1`.    
The string is composed by a plateau size, defined by x and y, and a list of rovers, each being defined by a initial position (x and y) and direction (N, S, E or W), followed by a list of actions.     
Rover's actions are processed one by one, one rover at a time.

**For example**  
The following input
```
5 5
1 2 N
LMLMLMLMM
3 3 E
MMRMMRMRRM
iex> Mars.execute("5 5\n1 2 N\nLMLMLMLMM\n3 3 E\nMMRMMRMRRM")
```
Should have the following output:

```
1 3 N
5 1 E
iex> "1 3 N\n5 1 E"
```

Impossible actions (moving rovers out of the plateau or inside another rover) are ignored.  

The function also create an image, representing the rovers actions.  

For example, running the last example, will result in this image.    
*Green squares represents a rover initial point, the red squares represents the final point and the orange line represents the path*  
![Sample result image](https://github.com/arturnista/mars_rovers_exstudy/raw/master/sample_result_image.png)

## Testing  
The whole Mars module is well tested and was developer under TDD (Test driven development) practices.
You can run the tests by running:    
```
$ mix test  
```

## Docs  
The modules are also well documented using ex_docs.  

You can generate the documentation by running:  
```
$ mix docs
```

