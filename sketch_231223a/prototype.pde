import java.util.ArrayList;
import java.util.HashSet;
import java.util.HashMap;
import java.util.Map;
import java.util.Arrays;
import java.util.List;
import java.util.Set;


class Point {
    
    float x;
    float y;
    float z;
    
    Point(float x, float y, float z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    float getX() {
        return x;
    }

    void setX(float x) {
        this.x = x;
    }

    float getY() {
        return y;
    }

    void setY(float y) {
        this.y = y;
    }

    float getZ() {
        return z;
    }

    void setZ(float z) {
        this.z = z;
    }
    
    
    boolean equals(Point p){
      return ((p.getX() == getX()) && (p.getY() == getY()) && (p.getZ() == getZ()));  
    }
    
    Point moyenne(ArrayList<Point> points) {
        float sumX = 0, sumY = 0, sumZ = 0;
        int n = points.size();
        for (Point p : points) {
            sumX += p.getX();
            sumY += p.getY();
            sumZ += p.getZ();
        }
        sumX = sumX / n;
        sumY = sumY / n;
        sumZ = sumZ / n;
        return new Point(sumX, sumY, sumZ);
    }
     
    @Override
    String toString(){
      return "X : " + getX() + ", Y : " + getY() + ", Z : " + getZ(); 
    }

}

class Arete {
    
    Point debut;
    Point fin;

    Point getMilieu() {
        float x = (debut.getX() + fin.getX()) / 2;
        float y = (debut.getY() + fin.getY()) / 2;
        float z = (debut.getZ() + fin.getZ()) / 2;
        return new Point(x, y, z);
    }

    
    Point getDebut() {
        return debut;
    }

    void setDebut(Point debut) {
        this.debut = debut;
    }

    Arete(Point debut, Point fin) {
        this.debut = debut;
        this.fin = fin;
    }
    
    Point getFin() {
        return fin;
    }
    void setFin(Point fin) {
        this.fin = fin;
    }
    public void dessiner() {
        line(debut.getX(), debut.getY(), debut.getZ(), fin.getX(), fin.getY(), fin.getZ());
    }
    
    @Override
    String toString(){
       return "Debut : "+ debut.toString() + "Fin : " +fin.toString() + "\n"; 
    }
    

}


class Face {
    ArrayList<Arete> liste;

    ArrayList<Arete> getListe() {
        return liste;
    }

    void ajouterArete(Arete arete){
        liste.add(arete);
    }

    Face(ArrayList<Arete> liste) {
        this.liste = liste;
    }
    
    void setListe(ArrayList<Arete> liste) {
        this.liste = liste;
    }
    
    Boolean isAdjacente(Arete arete){
      int is = 0;
      Point d = arete.getDebut();
      Point f = arete.getFin();
      for(Arete a : liste){
        Point d1 = a.getDebut();
        Point f1 = a.getFin();
        if(d.equals(d1)) is++;
        if(d.equals(f1)) is++;
        if(f.equals(d1)) is++;
        if(f.equals(f1)) is++;
      }
      is /=2;
      //println(is);
      return is == 2;
    }
    
    ArrayList<Point> obtenirPointsUniques() {
        ArrayList<Point> pointUnique = new ArrayList<Point>();
        for (Arete arete : liste) {
            if(!pointUnique.contains(arete.getDebut())){
              pointUnique.add(arete.getDebut());
            }
            if(!pointUnique.contains(arete.getFin())){
              pointUnique.add(arete.getFin());
            }
        }
        return pointUnique;
    }
    
    Point getCentre() {
        float sumX = 0;
        float sumY = 0;
        float sumZ = 0;
        int count = 0;

        // Supposons que la liste contient une séquence fermée d'aretes formant un polygone
        for (Arete arete : liste) {
            sumX += arete.getDebut().getX();
            sumY += arete.getDebut().getY();
            sumZ += arete.getDebut().getZ();
            count++;
        }

        // Si les aretes forment un polygone fermé, le dernier point est le meme que le premier
        // et ne devrait pas etre compté deux fois. Sinon, ajoutez le point final de la dernière arete.
        if (!liste.get(0).getDebut().equals(liste.get(liste.size() - 1).getFin())) {
            sumX += liste.get(liste.size() - 1).getFin().getX();
            sumY += liste.get(liste.size() - 1).getFin().getY();
            sumZ += liste.get(liste.size() - 1).getFin().getZ();
            count++;
        }

        return new Point(sumX / count, sumY / count, sumZ / count);
    }
    
    public void dessiner() {
      beginShape();
        for (Arete arete : liste) {
            vertex(arete.getDebut().getX(), arete.getDebut().getY(), arete.getDebut().getZ());
            vertex(arete.getFin().getX(), arete.getFin().getY(), arete.getFin().getZ());
        }
        
      endShape(CLOSE);
    }
    
    @Override
    String toString(){
       String pattern = "";
       for(int i = 0; i < liste.size(); i++){
         pattern = pattern + liste.get(i).toString();
       }
       return pattern + "\n"; 
    }

}


class Maillage {
    private ArrayList<Face> liste;
    
    private ArrayList<Face> listeOriginel;

    Maillage(ArrayList<Face> liste) {
        this.liste = liste;
        this.listeOriginel = liste;
    }
    ArrayList<Face> getListe() {
        return liste;
    }
    
    void reset(){
      this.liste = this.listeOriginel;
    }
    
    void setListe(ArrayList<Face> liste) {
        this.liste = liste;
    }
    
    Maillage Catmull_Clark() {
        
        HashMap<Point, Point> nouveauxSommets = new HashMap<Point, Point>();
        
        HashMap<Arete, ArrayList<Face>> areteAuxFaces = new HashMap<>();
        HashMap<Point, Point> nouveauxMilieu = new HashMap<Point, Point>();
        
        // Construction des nouveaux sommets centraux des aretes
        // Construire la carte des arêtes aux faces
        Point cle, valeur;
        for (Face face : liste) {
            for (Arete arete : face.getListe()) {
                float X = 0;
                float Y = 0; 
                float Z = 0; 
                Set<Point> cles = nouveauxMilieu.keySet();
                Boolean b = false;
                for (Point c : cles) {
                  if(c.equals(arete.getMilieu()))
                    b = true;
                }
                if(!b){
                  cle = arete.getMilieu();
                  for (Face fc : liste) {
                    if(fc.isAdjacente(arete)){
                      Point mf = fc.getCentre();
                      X += mf.getX();
                      Y += mf.getY();
                      Z += mf.getZ();
                    }
                  }
                  X += arete.getDebut().getX(); X += arete.getFin().getX(); X = X / 4;
                  Y += arete.getDebut().getY(); Y += arete.getFin().getY(); Y = Y / 4;
                  Z += arete.getDebut().getZ(); Z += arete.getFin().getZ(); Z = Z / 4;
                  valeur = new Point(X, Y, Z);
                  
                  if(face.isAdjacente(arete)){
                    nouveauxMilieu.put(cle,valeur);
                  }
                }
                //println(nouveauxMilieu.size());
                
                areteAuxFaces.putIfAbsent(arete, new ArrayList<>());
                areteAuxFaces.get(arete).add(face);
            }
        }
        // Calculer les nouveaux points de milieu des arêtes
        HashMap<Arete, Point> nouveauxPointsMilieu = new HashMap<>();
        for (Map.Entry<Arete, ArrayList<Face>> entry : areteAuxFaces.entrySet()) {
            Arete arete = entry.getKey();
            List<Face> facesAdj = entry.getValue();
    
            Point A = arete.getMilieu(); // Point actuel de l'arête
            Point F = facesAdj.get(0).getCentre(); // Centre de la première face adjacente
            Point E = (facesAdj.size() > 1) ? facesAdj.get(1).getCentre() : F; // Centre de la deuxième face adjacente, s'il existe
    
            Point M = new Point((arete.getDebut().getX() + arete.getFin().getX()) / 2,
                                (arete.getDebut().getY() + arete.getFin().getY()) / 2,
                                (arete.getDebut().getZ() + arete.getFin().getZ()) / 2); // Point moyen des sommets de l'arête
    
            // Calculer le nouveau point du milieu selon la formule (A + F + M + E)/4
            float x = (A.getX() + F.getX() + M.getX() + E.getX()) / 4;
            float y = (A.getY() + F.getY() + M.getY() + E.getY()) / 4;
            float z = (A.getZ() + F.getZ() + M.getZ() + E.getZ()) / 4;
            
            nouveauxPointsMilieu.put(arete, new Point(x, y, z));
        }
        
        
        
        // Pour chaque sommet, trouver toutes les aretes et faces adjacentes
        for (Face face : liste) {
            ArrayList<Point> pointsFace = face.obtenirPointsUniques();

            for (Point p : pointsFace) {
                ArrayList<Point> pointsArete = new ArrayList<Point>();
                ArrayList<Point> pointsFaceAdjacente = new ArrayList<Point>();

                // Collecter les points des aretes adjacentes
                for(Face fc : liste){
                  ArrayList<Arete> l = fc.getListe();
                  Boolean ml = false;
                  for (Arete arete : l) {
                      if (arete.getDebut().equals(p) || arete.getFin().equals(p)) {
                          if(!pointsArete.contains(arete.getMilieu())){
                            for(Point pm : pointsArete){
                              if(pm.getX() == arete.getMilieu().getX() &&
                                 pm.getY() == arete.getMilieu().getY() &&
                                 pm.getZ() == arete.getMilieu().getZ()
                                ){
                                    ml = true;
                              }
                            }
                            if(!ml)
                              pointsArete.add(arete.getMilieu());
                          }ml = false;
                      }
                  }
                }
                

                // Collecter les centres des faces adjacentes
                for (Face f : liste) {
                    if (f.obtenirPointsUniques().contains(p)) {
                        pointsFaceAdjacente.add(f.getCentre());
                    }
                }
                
                // Calculer la moyenne des points des aretes et des centres des faces
                Point stc = new Point(0,0,0);
                Point moyenneAretes = stc.moyenne(pointsArete);
                Point moyenneFaces = stc.moyenne(pointsFaceAdjacente);

                int n = pointsArete.size(); // Nombre d'aretes adjacentes
                Point P = p; // Le sommet original

                // Appliquer la formule pour trouver le nouveau point de sommet
                float x = (moyenneFaces.getX() + 2 * moyenneAretes.getX() + (n - 3) * P.getX()) / n;
                float y = (moyenneFaces.getY() + 2 * moyenneAretes.getY() + (n - 3) * P.getY()) / n;
                float z = (moyenneFaces.getZ() + 2 * moyenneAretes.getZ() + (n - 3) * P.getZ()) / n;
                // Stocker le nouveau sommet dans la carte
                nouveauxSommets.put(p, new Point(x, y, z));
            }
        }

       
        ArrayList<Face> nf = new ArrayList<Face>();
        
        for (Face face : liste) {
            Point centreFace = face.getCentre();
            
            ArrayList<Arete> aretes = face.getListe();
            ArrayList<Point> pointsFace = new ArrayList<Point>();
        
            for(Arete arete : aretes){
              if(!pointsFace.contains(arete.getDebut())){
                pointsFace.add(arete.getDebut());
              }
              if(!pointsFace.contains(arete.getFin())){
                pointsFace.add(arete.getFin());
              }
            }
              Point A = nouveauxSommets.get(pointsFace.get(0)); 
              Point B = nouveauxSommets.get(pointsFace.get(1)); 
              Point C = nouveauxSommets.get(pointsFace.get(2));
              Point D = nouveauxSommets.get(pointsFace.get(3));
              
              //Point F = nouveauxPointsMilieu.get(face.getListe().get(0));
              //Point G = nouveauxPointsMilieu.get(face.getListe().get(1));
              //Point H = nouveauxPointsMilieu.get(face.getListe().get(2));
              //Point I = nouveauxPointsMilieu.get(face.getListe().get(3));
              
              //println(nouveauxMilieu.size());
              
              Point F = face.getListe().get(0).getMilieu();
              Point G = face.getListe().get(1).getMilieu();
              Point H = face.getListe().get(2).getMilieu();
              Point I = face.getListe().get(3).getMilieu();
              
              for (Map.Entry<Point, Point> entry : nouveauxMilieu.entrySet()) {
                  Point ky = entry.getKey();
                  Point vl = entry.getValue();
      
                  if(ky.getX() == F.getX() && ky.getY() == F.getY() && ky.getZ() == F.getZ())
                    F = vl;
                    
                  if(ky.getX() == G.getX() && ky.getY() == G.getY() && ky.getZ() == G.getZ())
                    G = vl;
                    
                  if(ky.getX() == H.getX() && ky.getY() == H.getY() && ky.getZ() == H.getZ())
                    H = vl;
                    
                  if(ky.getX() == I.getX() && ky.getY() == I.getY() && ky.getZ() == I.getZ())
                    I = vl;
              }
              
              //Face 1 : A F cf I
              nf.add(new Face(new ArrayList<>(Arrays.asList(new Arete(A, F), new Arete(F, centreFace), new Arete(centreFace, I), new Arete(I, A)))));
        
             //Face 2 : F B G cf
              nf.add(new Face(new ArrayList<>(Arrays.asList(new Arete(F, B), new Arete(B, G), new Arete(G, centreFace), new Arete(centreFace, F)))));
              
              //Face 3 : cf G C H
             nf.add(new Face(new ArrayList<>(Arrays.asList(new Arete(centreFace, G), new Arete(G, C), new Arete(C, H), new Arete(H, centreFace)))));
              
              //Face 4 : I cf H D
              nf.add(new Face(new ArrayList<>(Arrays.asList(new Arete(I, centreFace), new Arete(centreFace, H), new Arete(H, D), new Arete(D,I)))));
              
              pointsFace.clear();
        }
       
        // Mettre à jour le maillage avec les nouvelles faces
        return new Maillage(nf);
    }
    
    
}
