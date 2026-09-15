class Particle {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float lifespan;
  color particleColor;
  color attractedColor = color(0, 255, 0);
  int rayon = 15;

  Particle() {
    position = new PVector(width/2, height/3);
    initialize();
    
  }

  Particle(PVector l) {
    position = l.copy();
    initialize();
  }

  void initialize() {
    velocity = new PVector(random(-2, 2), random(-3, 0));
    acceleration = new PVector(0, 0.05);
    particleColor = color(0, 0, 255);
    lifespan = 200;
  }

  void update(int deltaTime) {
    velocity.add(acceleration);
    position.add(velocity);
    lifespan -= 2.0;

    if(isDead()) {
      reset();
    }
  }

  void display() {
    stroke(0, lifespan);
    fill(particleColor, lifespan);
    ellipse(position.x, position.y, rayon, rayon);
  }

  boolean isDead() {
    return lifespan < 0.0;
  }

  void reset() {
    position.set (width/2,  height/3);
    velocity.set (random(-2, 2), random(-3, 3));
    acceleration.set(0, 0.05);
    particleColor = color(0, 0, 255);
    lifespan = 200;
  }
  
  void applyForce(PVector force){
    this.acceleration.add(force);
  }
  
  void isAttracted(){
    particleColor = attractedColor;
  }
  
  void isNotAttracted(){
    particleColor = color(0, 0, 255);
  }
}
