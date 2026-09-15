int currentTime;
int deltaTime;
int previousTime;
int PARTICLE_RATE = 10;
int BACKGROUND_COLOR = 255;
PVector EMITTER_INIT_POSITION;


Emitter emitter;

Player player;

void setup() {
  size(800, 500, P2D);
  EMITTER_INIT_POSITION = new PVector(width / 2, height / 4);
  emitter = new Emitter (EMITTER_INIT_POSITION, PARTICLE_RATE);

  player = new Player();
}

void draw() {
  currentTime = millis();
  deltaTime = currentTime - previousTime;
  previousTime = currentTime;

  update(deltaTime);
  display();
}

void update(int deltaTime) {
  player.update();
  emitter.applyActraction(player);
  emitter.update(deltaTime);

}

void display() {
  background(BACKGROUND_COLOR);

  emitter.display();

  player.display();
}
