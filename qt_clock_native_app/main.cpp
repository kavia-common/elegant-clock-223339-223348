#include <QApplication>
#include <QLabel>
#include <QTimer>
int main(int argc, char **argv){ QApplication a(argc, argv); QLabel l("Qt Headless Test"); l.show(); // quit shortly to make test deterministic
 QTimer::singleShot(200, &a, &QCoreApplication::quit); return a.exec(); }
