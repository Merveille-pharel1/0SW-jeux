class Player{
  int rayon = 20;
  PVector position;
  PVector velocity;
  color pColor = color(0, 0, 0);
  int power;
  int minDistance = 5;
  int maxDistance = 50;
  
  Player(){
    position = new PVector(rayon, height - rayon);
    velocity = new PVector(3, 0);
    this.power = 200;
  }
  
  void update(){
    if(keyPressed){
    
      if(key == 'a' || key == 'A'){
          position.sub(velocity);
          this.position.x = constrain(this.position.x, rayon, width - rayon);
      }
      else if(key == 'd' || key == 'D'){
          position.add(velocity);
          this.position.x = constrain(this.position.x, rayon, width - rayon);

      }
    }
    
  }
  
  PVector attraction(Particle particle){
    PVector force = PVector.sub(this.position, particle.position);
    
    float distance = force.mag();
    
    distance = constrain(distance, minDistance, maxDistance);
    float strength = this.power / (distance * distance);
    force.setMag(strength);
    return force;
  }
  
  void display(){
    stroke(0);
    fill(pColor);
    circle(this.position.x, this.position.y, rayon * 2);
  }
}
