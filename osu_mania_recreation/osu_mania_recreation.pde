import java.util.Iterator; // import for the iterator
import processing.sound.*; // import for the sound library
NoteManager nManager; // note manager instance
SoundFile file; // sound file sound effect

int size = 30; // circle size
int offset = (4*size)+size/2; // offset of the cirlce
int spacing = 53; // spacing between the circle

String[] beatmap; // string array to load notes

hitCircle circleD, circleF, circleJ, circleK; // hit circles
ArrayList<hitCircle> circles; // arraylist of hit circles

void loadMap() { // function to load map
  for (int noteY = 0; noteY < beatmap.length; noteY++) { // looping through the lines in the file
    String currNote = beatmap[noteY]; // setting the line to note
    String timing = ""; // string to hold the timing of the note
    int col = Integer.parseInt(str(currNote.charAt(0))); // column of the note
    Boolean decimal = false; // boolean controlling if there is a decimal

    timing += currNote.charAt(2); // adding the first number of the timing
    for (int x = 0; x < currNote.length(); x++) { // looping through the rest of the timing
      if (currNote.charAt(x) == '.') { // if there is a decimal point
        decimal = true; // set decimal to true
        timing += '.'; // add a decimal to the timing
        continue; // go to the next number
      }
      if (decimal == true) { // if there was a decimal
        timing += currNote.charAt(x); // add the number to the timing
      }
    } // end of for loop
    float realTime = Float.parseFloat(timing); // parse the string timing into a float
    nManager.notes.add(new Note (col, realTime*1000)); // add the note into the note manager
  } // end of for loop
} // end of function

void keyPressed() { // function to handle key presses
  circleD.setCircle(); // activate the hit circle
  circleF.setCircle(); // activate the hit circle
  circleJ.setCircle(); // activate the hit circle
  circleK.setCircle(); // activate the hit circle
} // end of function

void keyReleased() { // function to handle key releases
  circleD.circleRelease(); // release the hit circle
  circleF.circleRelease(); // release the hit circle
  circleJ.circleRelease(); // release the hit circle
  circleK.circleRelease(); // release the hit circle
} // end of function


void setup() { // function to setup
  size(1280, 720); // the screen size
  beatmap  = loadStrings("beatmap.txt"); // loads the beatmap
  nManager = new NoteManager(); // initializing the note manager
  file = new SoundFile(this, "hitsound.mp3"); // loads the hit sound file
  circleD = new hitCircle(0, 'd'); // values for the first hit circle
  circleF = new hitCircle(1, 'f'); // values for the second hit circle
  circleJ = new hitCircle(2, 'j'); // values for the third hit circle
  circleK = new hitCircle(3, 'k'); // values for the fourth hit circle
  circles = new ArrayList<hitCircle>(); // initialize the array list
  circles.add(circleD); // adds the hit circle to the array list
  circles.add(circleF); // adds the hit circle to the array list
  circles.add(circleJ); // adds the hit circle to the array list
  circles.add(circleK); // adds the hit circle to the array list
  frameRate(60); // sets the frame rate to 60
  loadMap(); // runs the map

}
class hitCircle { // beginning the hit circle class
  int col; // column
  int y; // y position
  boolean noteHit; // variable if the note is hit
  boolean isHeld; // variable if the key is held
  float lastPress = millis(); // the last time the key was pressed
  float holdTime = 20000; // maximum hold time
  char circleChar; // the key of the hit circle
  int fadeClr; // color of the fade

  hitCircle(int c, char noteKey) { // constructor of the hit circle class
    col = c; // setting the column
    circleChar = noteKey; // setting the key
    noteHit = false; // setting the note hit
    isHeld = false; // setting held variable
    fadeClr = 255; // setting the fade
    y = height - 40; // settting the y position
  }

  void checkTime() { // function to check the time
    if (millis() - lastPress >= holdTime) { // if the current time is greater than the hold time
      lastPress = millis(); // setting the last time pressed
      isHeld = true; // setting the key to held
    }
  } // end of function
  void setCircle() { // function to set the circle
    if (key == circleChar && keyPressed) { // if the hit circle is pressed
      noteHit = true; // set the note to pressed
      checkTime(); //  run check time
    }
  } // end of function
  void circleRelease() { // function to handle when the hit circle is released
    if (key == circleChar) { // if the hit circle was pressed
      noteHit = false; // setting the note to not be hit
      isHeld = false; // setting the note to not be held
    }
  } // end of function
  void updateNote() { // function of updating the hit circle notes
    noFill(); // remove the fill
    ellipse((col*size)+offset+(spacing*(col+1)), y, size+20, size+20); // display the hit circle

    if (noteHit == true) { // if the note is hit
      fadeClr =255; // set the fade to max
      fill(fadeClr); // fill with the fade
      ellipse((col*size)+offset+(spacing*(col+1)), y, size+20, size+20); // display the hit circle
      if (nManager.checkCollide(y, col)) { // if the hit circle is colliding with a note
        file.play(); // play sound effect
        isHeld = true; // set the note to be held
      }
    }

    if (noteHit == false) { // if the note is not held 
      if (fadeClr > 0) { // if the fade is not completed
        fill(fadeClr); // fill with the fade
        ellipse((col*size)+offset+(spacing*(col+1)), y, size+20, size+20); // display the hit circle
        fadeClr-=35; // decrease the fade
      }
    }
  } // end of function
} // end of class

void draw() { // function to draw
  background(0); // clear the screen

  int colSize = 30; // set the column size


  circleD.updateNote(); // update the hit circle
  circleF.updateNote(); // update the hit circle
  circleJ.updateNote(); // update the hit circle
  circleK.updateNote(); // update the hit circle

  stroke(255); // set the stroke
  strokeWeight(2); // set the stroke weight
  line((4*colSize)+colSize/2, 0, (4*colSize)+colSize/2, height); // create left border
  line((16*colSize)+colSize/2, 0, (16*colSize)+colSize/2, height); // create right border
  nManager.run(); // run the note manager
}







class Note { // the note class
  Note (int column, float fall) { // constructor for the note
    col = column; // setting the column
    size = 30; // setting the size
    offset = (4*size)+size/2; // setting the offset
    y=0; // setting the y position
    spacing = 53; // setting the spacing
    missed = false; // setting the missed variable
    fallDown = int(fall); // setting the time to fall down
  }
  boolean isReady() { // function to check if the note is ready to fall down
    return millis() >= fallDown; // return true or false if the note is ready
  } // end of function
  void display() { // function to display the note
    stroke(255); // setting the stroke
    strokeWeight(2); // setting the stroke weight
    fill(0, 0, 255); // filling with blue
    ellipse((col*size)+offset+(spacing*(col+1)), y, size+20, size+20); // drawing the note
  } // end of function

  void update() { // function to update the note
    y+=8; // add to the y position
  } // end of the update

  void isMissed() { // function if the note is missed
    if (y > height-10) { // if the note has reached the bottom
      missed = true; // set missed to true
    }
  } // end of function

  void run() { // function to run the note
    if (isReady()) { // if the note is ready
      isMissed(); // check if the note is missed
      update(); // update the note
      display(); // display the note
    }
  } // end of function

  int getCol() { // function to get the col of the note
    return col; // return the column
  }
  int col; // column variable
  int y; // y variable
  int size; // size variable
  int offset; // offset variable
  int spacing; // spacing variable
  boolean missed; // missed variable
  int fallDown; // fall down variable
}

class NoteManager { // note manager class
  ArrayList<Note> notes; // array list to hold the notes

  NoteManager() { // constructor for the note manager
    notes = new ArrayList<Note>(); // initalize the notes
  }

  void run() { // function to run the notes in the array list
    Iterator<Note> it = notes.iterator(); // create an iterator of the note array list
    while (it.hasNext()) { // while there is more notes in the array list
      Note n = it.next(); // get the current note
      n.run(); // run the note
      if (n.missed) { // if the note missed
        it.remove(); // remove the note from the array list
      }
    } // end of while loop
  } // end of function

  boolean checkCollide(int hitCircle, int hitCircleCol) { // function to check collision
    for (Note n : notes) { // loop through the notes in the array list
      if (n.getCol() == hitCircleCol ) { // if the note is in the same column as the hit circle

        if ((n.y + n.size+20) >= hitCircle && !circles.get(hitCircleCol).isHeld) { // if the note is colliding with the hit circle
          n.missed = true; // clear the note
          return true; // return a collision
        }
      }
    } // end of for loop
    return false; // return no collisions
  } // end of function
}
