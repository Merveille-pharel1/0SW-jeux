class Emitter {
  PVector position;
  int particleRate;
  int lastParticleTime;
  ArrayList<Particle> particles;
  int maxParticles = 2000;
  float reactionDistance = 100;

  Emitter(PVector l, int rate) {
    position = l.copy();
    particleRate = rate;
    lastParticleTime = 0;
    particles = new ArrayList<Particle>();
  }

  void update(int deltaTime) {
    if (millis() - lastParticleTime > particleRate && particles.size() < maxParticles) {
      lastParticleTime = millis();
      particles.add(new Particle(position));
    }

    for (Particle p : particles) {
      p.update(deltaTime);
    }
  }

  void display() {
    for (Particle p : particles) {
      p.display();
    }
  }
  
  void applyActraction(Player player){
    
    for(Particle p : particles){
      
      PVector direction = PVector.sub(player.position, p.position);
      float distance = direction.mag();
      
      if(distance < reactionDistance){
        PVector force = player.attraction(p);
        p.applyForce(force);
        p.isAttracted();
      }
      else{
        p.isNotAttracted();

      }
    }
  }
  
  void setDistance(float distance){
    this.reactionDistance = distance;
  }
}
