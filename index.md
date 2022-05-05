### Contents

- [Problem Definition](https://github.com/mlk-713/cs766_project/edit/gh-pages/index.md#problem-definition)
- [Motivation](https://github.com/mlk-713/cs766_project/edit/gh-pages/index.md#motivation)
- [Approach](https://github.com/mlk-713/cs766_project/edit/gh-pages/index.md#approach) (is this different from implementation?)
- [Implementation](https://github.com/mlk-713/cs766_project/edit/gh-pages/index.md#implementation)
- [Results Discussion](https://github.com/mlk-713/cs766_project/edit/gh-pages/index.md#results-discussion)
- [Problems and Possible Improvements](https://github.com/mlk-713/cs766_project/edit/gh-pages/index.md#problems-and-possible-improvements)
- [Gallery](https://github.com/mlk-713/cs766_project/edit/gh-pages/index.md#gallery)

## Problem Definition
  For our project we decided to create a computer vision program that is capable of "playing" the game pick-up sticks.  In the game of pick-up sticks, players take turns trying to remove sticks from a random pile without disturbing the other sticks.  During their turn, a player can continue to pick up individual sticks until they either cause a disturbance or deplete the pile.  With this in mind, we focused on designing a program capable of describing an optimal order in which to continuously pick up sticks without disturbing other sticks.  To help maintain a reasonable scope for the project we decided to ignore the point system and advanced rules of pick-up sticks.  We also required that each stick be a unique color, which also ended up limiting the max number of sticks we could include in our test images.  This gave as a simple, clearly defined goal for the project; given an image of a simple pile of sticks, describe a best order in which to pick them up.

## Motivation

  At its core this problem encompasses fundamentals of computer vision such as edge detection and object identification while also providing a simple foundation for exploring more complex topics as time allows.  As an example, we might improve our program’s design by adding some form of consideration for the physics that govern one stick’s behavior when another stick is removed.

## Approach
  This objective is similar to that of a well known problem, bin picking. In bin picking, the objective is to identify objects in a bin and retrieve them. The differences between pick-up sticks and bin picking include the need to remove objects without interfering with other objects, and determining the order in which you need to retrieve the objects.  There were little to no previous research in the area of pick-up sticks, and we decided to approach this problem algorithmically rather than using a machine learning process because of the lack of good training datasets.
  
  The first steps will certainly be to create datasets to test and refine our algorithm. Next, we need to process the image and develop a way to recognize the individual sticks that make up a pile.  From there, we need to get other features of the pile such as the points where sticks overlap. Finally, we need to output the order of sticks from the ones on top to the bottom. Finally, we looked into factoring in load bearing sticks.

## Implementation
  First we gathered sample sets of a few pick-up sticks to work with. We started by experimenting with a few different backgrounds, but eventually settled on just using a simple black paper background.  Once that was decided, we positioned a camera above the scene and captured multiple sample images without changing its position.  The images captured this way were zoomed out farther than desired, so we then cropped them all to better focus on the region of interest while keeping them all the same size.  These images only contain a few sticks, less than ten, and the sticks are either all in different colors or all in the same color.  Having developed a clear method for capturing images, once we get the project working on the simple set of images, we can then easily create more complex images for further testing and development.
  
  We will use the following image as a running example throughout our explanation of our implementation:
  
  ![base image](./simple_mc_6_6.png)
  
  Next, given these pictures, we first tried to clean up the results. Ideally we wanted to use the hough line detection methodology to identify the lines that represented the pickup sticks. This required converting this image to black and white. Unfortunately, our background was not precisely black, or otherwise this would be quite trivial. Because of this, we first converted these images to grayscale, and utilized the following imbinarize code:
  
```matlab
bw_img=imbinarize(trim_gray_img,'adaptive','ForegroundPolarity','bright','Sensitivity',0.5);
```

  This got us pretty clean black and white image to work with, and we used dilation and erosion to finalize the cleaning process. Next, we needed to find the lines representing the pickup sticks. We utilized Hough peaks and Hough lines in order to do so: 

```matlab
[H,T,R] = hough(clean_img);
P  = houghpeaks(H,6,'threshold',ceil(0.5*max(H(:))));
lines = houghlines(clean_img,T,R,P,'FillGap',5,'MinLength',7);
```

  However, these hough lines weren’t the most clean. While they did encompass the 6 pickup sticks, there were noise hough lines that were either very short or very long. Thus, we went through and found the average length of the hough lines (hoping that this represented the general length of the pickup sticks) and only selected hough lines that fit within a boundary of this average. This yielded great results, as seen below.
  
  ![line example](./lines_example.png)

  Once we had the lines, we needed to figure out where the sticks intersected since those are the points of interest in a game of pick-up sticks. In order to do so, we utilized line equations and determinants in order to find every possible combination of intersections among the lines. This requires (n-1)+(n-2)+...+(1) calculations, which isn’t too bad. Finally, we only save the intersections that lie on both of the lines (since intersections can be a point in the distance where the points eventually intersect).  This gave us the following resulting view when plotted with the lines.
  
  ![intersection example](./intersection_example.png)

  With the intersections, it is possible to save the lines involved in the intersections, and the next challenge is identifying the stick at the top. We ised a simpler version of pick-up sticks where each of the sticks are of different color. This allows us to do pixel analysis on the original image. We essentially take both lines involved, and run:

```matlab
improfile(img,testx,testy)
```

  This function helps us analyze the pixel intensities of the color channels. We then looked at the two lines involved in each intersection, and calculate their average pixel intensities across the entire line as a baseline. We took a small region of interest around the intersection point, and averaged the pixel intensities there. Finally, we compared the profile of the region of interest with both of the lines in order to determine which line matched the region of interest closest (which indicates which stick is on top). 

  Once we aquired the top stick information, we could then scan through all the intersections and create to create a digraph representing the pile.  In this representation, sticks were converted to nodes, and overlap points became edges, with the edge starting at the node representing the top stick and going into the node representing the bottom stick.  We did this in code by creating a matrix representation of the digraph.  We then called the graph() function on the matrix to get our digraph. Our running example's digraph, simplified slightly for clarity, is pictured on the left with the stick labels shown on the right for reference:
  
  <p align="center">
  <img width="400" src="./digraph_example.png"> <img width="400" src="./labels_digraph_example.png">
  </p>
  
  Using the digraph representation, we simply called the toposort() function and got a topological ordering of the nodes, and therefore the sticks.  As a final step we modify this order to prioritize isolated sticks as first in the order.  Once this is done, we have our order for picking up the sticks and can display it on the original image as our final output:
  
  ![example output](./simple_mc_6_6-out.png)

  We also looked at the possibility of detecting load bearing sticks, sticks that weigh down other sticks. Removal of load bearing sticks could cause other sticks to tilt or move. While the algorithm is far from perfect due to time constraints, it provides a proof of concept for feasibility of accomplishing this task. Our algorithm first looks at sticks which could be affected by load bearing sticks. Essentially, we looked at all the intersection points that are associated with each stick, and only considers a stick to be potential "load-beared" stick if it has 2 or more intersection points (because it needs a pivot intersection underneath and a weight intersection on top). If a stick has 2 or more intersections an at least one intersection above and below, we attempt to find the right most and left most pivot. The intuition here is that any stick underneath another either to the right but not the right most or to the left but not left most cannot act as a pivot stick. Once we determied the pivot points, we check any sticks on top of the "load-beared" stick, and determine if it lies further away from the center than the pivot point. If it does, it should be classified as a load bearing stick.

## Results Discussion
  The results for our algorithm and identifying the order of sticks to pick up without disturbing other sticks underneath showed that our algorithm worked well. We tested many images with 3 or 4 differently colored sticks, as well as images with more sticks or load bearing sticks. In each case, the algorithm was able to correctly identify the sticks in question, and the ordering of sticks from top to bottom. The load bearing algorithm also identifies which sticks could be potentially load bearing, though there are improvements to be made. Notably, if there are multiple sticks that could be load bearing but can be removed in such a way that results in no load bearing, our algorithm just labels all possible load bearing sticks, and removes those without consideration of first removing non-load bearing in hopes that the result would make the other sticks non-load bearing. Another issue is the difficulty accounding for the weight of the pickup sticks, and in our load bearing results, we often mislabel non-load bearing sticks as possibly load bearing because the sticks didn't have enough weight to pivot the sticks below them.
  
## Problems and Possible Improvements
  Some improvements to this project could be to modify the load bearing algorithm to account for the weight of the pickup sticks since that affects whether a stick is truely load bearing. Another improvement could be to set up a score on difficulty of removal. For example, just because a stick is on top, doesn't mean it's the easiest stick to remove without disturbing other sticks. We could also improve our implementation of stick identification. Currently we use a hough line detection method, but there might be smarter and more robust ways to identify pickup sticks. Finally, figuring out a method to determine which stick is on top at each intersection that doesn't rely on color is important. In a game of pickup sticks, there are often many sticks with the same color, and if they overlap each other, our algorithm currently would have a difficult time identifying which stick is on top.
## Gallery

# Below this is just the default page text, it's useful to reference. (will delete later)

## Welcome to GitHub Pages

You can use the [editor on GitHub](https://github.com/mlk-713/cs766_project/edit/gh-pages/index.md) to maintain and preview the content for your website in Markdown files.

Whenever you commit to this repository, GitHub Pages will run [Jekyll](https://jekyllrb.com/) to rebuild the pages in your site, from the content in your Markdown files.

### Markdown

Markdown is a lightweight and easy-to-use syntax for styling your writing. It includes conventions for

```markdown
Syntax highlighted code block

# Header 1
## Header 2
### Header 3

- Bulleted
- List

1. Numbered
2. List

**Bold** and _Italic_ and `Code` text

[Link](url) and ![Image](src)
```

For more details see [Basic writing and formatting syntax](https://docs.github.com/en/github/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax).

### Jekyll Themes

Your Pages site will use the layout and styles from the Jekyll theme you have selected in your [repository settings](https://github.com/mlk-713/cs766_project/settings/pages). The name of this theme is saved in the Jekyll `_config.yml` configuration file.

### Support or Contact

Having trouble with Pages? Check out our [documentation](https://docs.github.com/categories/github-pages-basics/) or [contact support](https://support.github.com/contact) and we’ll help you sort it out.
