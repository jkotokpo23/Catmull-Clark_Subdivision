import controlP5.*;

ControlP5 cp5;
int subdivisionLevel = 0;
int maxsub = 5;
Maillage maillage;
float zoom = 1;
float angleX = 0;
float angleY = 0;
static int PAGE = 0;
PGraphics scene3D;

void setup() {
    size(800, 600, P3D);
    cp5 = new ControlP5(this);

    cp5.addButton("toIndex")
       .setPosition(190, 60)
       .setSize(80, 40)
       .setLabel("Accueil");
       
    cp5.addButton("toDraw")
       .setPosition(100, 60)
       .setSize(80, 40)
       .setLabel("Visualiser");

    maillage = creerMaillageTore(); // Fonction pour créer un maillage initial
}


void draw() {
    if(PAGE == 1){
      background(32,138,130);
      lights();
      translate(width / 2, height / 2);
      scale(zoom);
      rotateY(angleY);
      rotateX(angleX);
      for (Face face : maillage.getListe()) {
          face.dessiner();
      }

    }else{
      
    }
}

void toDraw() {
    PAGE = 1; // Changez la valeur pour afficher la page de visualisation
}

void toIndex() {
    PAGE = 0; // Changez la valeur pour afficher la page de visualisation
}



void subdivisionLevel(int newLevel) {
    if (newLevel != subdivisionLevel) {
        subdivisionLevel = newLevel;
        resetMaillage();// Réinitialiser le maillage à l'état initial

        for (int i = 0; i < subdivisionLevel; i++) {
            maillage = maillage.Catmull_Clark(); // Appliquer la subdivision
        }
    }
}

void mouseDragged() {
    angleY += (mouseX - pmouseX) * 0.01;
    angleX += (mouseY - pmouseY) * 0.01;
}

void mouseWheel(MouseEvent event) {
    float e = event.getCount();
    zoom += e * 0.05;
    zoom = constrain(zoom, 0.5, 3); // Limiter le zoom
}

void resetMaillage() {
    maillage = creerMaillageTore();
    subdivisionLevel = 0;
}

void keyPressed() {
    if (key == ENTER || key == RETURN) {
        incrementSubdivisionLevel();
        println("Bouton");
        println(subdivisionLevel);
    }
    if (key == ' ') {
        maillage.reset();
        resetMaillage();
        
    }
    if (key == 'R' || key == 'r') {
        decrementSubdivisionLevel();
    }
}


void incrementSubdivisionLevel() {
    if(subdivisionLevel < maxsub){
      subdivisionLevel++;
      applySubdivision();
    }
}

void decrementSubdivisionLevel() {
    if(subdivisionLevel > 0){
      subdivisionLevel--;
      applySubdivision();
    }
}

void applySubdivision() {
    maillage = creerMaillageTore(); // Réinitialiser le maillage
    
    for (int i = 0; i < subdivisionLevel; i++) {
        maillage = maillage.Catmull_Clark(); // Appliquer la subdivision   
    }
}


Arete creerArete(Point debut, Point fin) {
    return new Arete(debut, fin);
}

Face creerFace(Arete a1, Arete a2, Arete a3, Arete a4) {
    ArrayList<Arete> aretes = new ArrayList<Arete>();
    aretes.add(a1);
    aretes.add(a2);
    aretes.add(a3);
    aretes.add(a4);
    return new Face(aretes);
}

Maillage creerMaillageCubique() {
    // Définir les sommets du cube
    int scale = 100;
    Point p1 = new Point(-1 * scale, -1 * scale, -1 * scale);
    Point p2 = new Point(1 * scale, -1 * scale, -1 * scale);
    Point p3 = new Point(1 * scale, 1 * scale, -1 * scale);
    Point p4 = new Point(-1 * scale, 1 * scale, -1 * scale);
    Point p5 = new Point(-1 * scale, -1 * scale, 1 * scale);
    Point p6 = new Point(1 * scale, -1 * scale, 1 * scale);
    Point p7 = new Point(1 * scale, 1 * scale, 1 * scale);
    Point p8 = new Point(-1 * scale, 1 * scale, 1 * scale);

    // Créer les faces du cube
    ArrayList<Face> faces = new ArrayList<Face>();
    faces.add(creerFace(new Arete(p1, p2), new Arete(p2, p6), new Arete(p6, p5), new Arete(p5, p1))); // Face avant
    faces.add(creerFace(new Arete(p2, p3), new Arete(p3, p7), new Arete(p7, p6), new Arete(p6, p2))); // Face droite
    faces.add(creerFace(new Arete(p3, p4), new Arete(p4, p8), new Arete(p8, p7), new Arete(p7, p3))); // Face arrière
    faces.add(creerFace(new Arete(p4, p1), new Arete(p1, p5), new Arete(p5, p8), new Arete(p8, p4))); // Face gauche
    faces.add(creerFace(new Arete(p4, p3), new Arete(p3, p2), new Arete(p2, p1), new Arete(p1, p4))); // Face supérieure
    faces.add(creerFace(new Arete(p5, p6), new Arete(p6, p7), new Arete(p7, p8), new Arete(p8, p5))); // Face inférieure

    return new Maillage(faces);
}

Maillage creerMaillageGrille() {
    int scale = 100;
    int gridSize = 4; // Taille de la grille (nombre de carrés sur un côté)

    // Liste pour stocker les points et les faces
    ArrayList<Point> points = new ArrayList<Point>();
    ArrayList<Face> faces = new ArrayList<Face>();

    // Générer les points de la grille
    for (int i = 0; i <= gridSize; i++) {
        for (int j = 0; j <= gridSize; j++) {
            points.add(new Point(i * scale, 0, j * scale));
        }
    }

    // Créer les faces (carrés) de la grille
    for (int i = 0; i < gridSize; i++) {
        for (int j = 0; j < gridSize; j++) {
            int topLeft = i * (gridSize + 1) + j;
            int topRight = topLeft + 1;
            int bottomLeft = topLeft + (gridSize + 1);
            int bottomRight = bottomLeft + 1;

            faces.add(creerFace(new Arete(points.get(topLeft), points.get(topRight)),
                                new Arete(points.get(topRight), points.get(bottomRight)),
                                new Arete(points.get(bottomRight), points.get(bottomLeft)),
                                new Arete(points.get(bottomLeft), points.get(topLeft))));
        }
    }

    return new Maillage(faces);
}

Maillage creerMaillageTore() {
        int rayonPrincipal = 100;
        int rayonTube = 40;
        int nbSegments = 16;
        int nbCercles = 16;

        ArrayList<Point> points = new ArrayList<>();
        ArrayList<Face> faces = new ArrayList<>();

        // Générer les points du tore
        for (int i = 0; i < nbCercles; i++) {
            for (int j = 0; j < nbSegments; j++) {
                float angleCercle = (float) (2 * Math.PI * i / nbCercles);
                float angleSegment = (float) (2 * Math.PI * j / nbSegments);

                float x = (float) ((rayonPrincipal + rayonTube * Math.cos(angleSegment)) * Math.cos(angleCercle));
                float y = (float) ((rayonPrincipal + rayonTube * Math.cos(angleSegment)) * Math.sin(angleCercle));
                float z = (float) (rayonTube * Math.sin(angleSegment));

                points.add(new Point(x, y, z));
            }
        }

        // Créer les faces du tore
        for (int i = 0; i < nbCercles; i++) {
            for (int j = 0; j < nbSegments; j++) {
                int premier = i * nbSegments + j;
                int topRight = premier + 1;
                int bottomLeft = (i + 1) % nbCercles * nbSegments + j;
                int bottomRight = bottomLeft + 1;
        
                // Adjust for the last segment in each circle
                if (j == nbSegments - 1) {
                    topRight = i * nbSegments;
                    bottomRight = (i + 1) % nbCercles * nbSegments;
                }
        
                ArrayList<Arete> aretes = new ArrayList<>();
                aretes.add(new Arete(points.get(premier), points.get(topRight)));
                aretes.add(new Arete(points.get(topRight), points.get(bottomRight)));
                aretes.add(new Arete(points.get(bottomRight), points.get(bottomLeft)));
                aretes.add(new Arete(points.get(bottomLeft), points.get(premier)));
        
                faces.add(new Face(aretes));
            }
        }



        return new Maillage(faces);
    }
