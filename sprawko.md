# ASK Sprawozdanie
## Skrypty do wykonywania kopii bezpieczeństwa plików i repozytoriów w Linux

### Wstęp

### Skrypty

#### Tworzenie kopii zapasowych
Tworzenie kopii dla każdego typu danych jest bardzo podobnym procesem. Najpierw tworzymy raz w tygodniu (dokładnie w poniedziałek) pełną kopię, która zawiera pełną informację o plikach znajdujących się w folderze lub repozytorium. Następnie codziennie pojawia się dodatkowa kopia przyrostowa, która zawiera już tylko różnice względem poprzedniej kopii zapasowej. Warto wspomnieć, że dla ułatwienia skryptów przywracania kopii z konkretnego dnia oraz ustawień cykliczności, kopia dzienna tworzona jest również w dniu tworzenia pełnej kopii, oczywiście po jej stworzeniu. 

##### Pliki
Zacznę od opisu skryptów dla kopii bezpieczeństwa zwykłych plików. Postanowiliśmy użyć do tego celu narzędzia `tar`, dzięki czemu dane od razu są spakowane w skompresowane archiwum. 

Działanie skryptu tygodniowego zaczyna się od usunięcia pliku "snapshot", który zawiera metadane o obecnym stanie zarchwizowanego folderu potrzebne do poprawnego generowania kopii przyrostowych. Usuwamy go, gdyż zdecydowaliśmy, że ten plik ma stałą nazwę. Natomiast przy tworzeniu kopii, jeśli zostanie podana ścieżka do nieistniejącego (stąd usuwanie go) pliku to tworzona jest pełna kopia. Każde tygodniowe zestawienie kopii znajduje się w osobnym folderze, więc następnie tworzony jest folder dla nowego tygodnia, który zawiera w nazwie datę obecnego dnia. Potem jest najważniejsza część skryptu, czyli wywołanie komendy `tar`, która tworzy pełną kopię folderu.

Dodatkowo postanowiliśmy stworzyć skrót (symlink) do folderu dla kopii z obecnego tygodnia, dzięki czemu skrypt dzienny w łatwy sposób może odnaleźć właściwy folder. Zatem na zakończenie skryptu tygodniowego usuwany jest poprzedni skrót oraz tworzony skrót do obecnego folderu.

Codziennie wykonywane skrypty dla plików są bardzo proste i składają się tylko z jednej komendy. Jest to komenda `tar`, która jako argument ma obecną wersję pliku snapshot, dzięki czemu kopia zawiera tylko zmiany w plikach od poprzedniego wykonania kopii. Warto wspomnieć, że nazwa pliku zawiera numer porządkowy dnia tygodnia.

##### Git
Zasada działania jest tutaj taka sama, jednak repozytorium powoduje pewne dodatkowe problemy, zatem wymienię tylko różnice i dodane rzeczy względem tworzenia kopii plików.

Do stworzenia pełnej kopii wchodzimy do folderu z repozytorium i używamy komendy `git bundle` bez wskazania konkretnej poprzedniej wersji, czyli tworzymy kopię zawierającą wszystkie pliki wpisane do repozytorium. Następnie wykonujemy akcję, która jest odpowiednikiem tworzenia pliku snapshot. W tym przypadku tworzymy tag w repozytorium o stałej nazwie, który wskazuje na moment tworzenia kopii zapasowej. Potem na podstawie tego tagu możliwe jest stworzenie kopii inkrementalnej. Dodatkowo samodzielnie zapisujemy pełną scieżkę do folderu repozytorium w oddzielnym pliku, gdyż kopia poprzez `git` nie zawiera takiej informacji. Również wykonywanie kopii przez komendy `git` nie zawiera informacji o metadanych, takich jak właściciel pliku, czy prawa do odczytu. W celu zapisania tych informacji wykonujemy tutaj stworzony przez nas skrypt. ~~**Zasada działania tego skryptu i ogólnie zapisywania i odzyskiwania praw znajduje się w osobnej części.**~~ Ostatnia rzecz do wykonania to skompresowanie i zarchwizowanie stworzonych plików do czego wykorzystujemy ponownie narzędzie `tar`.

Natomiast codzienne kopie przyrostowe są tworzne tylko, jeśli były zmiany od stworzenia tagu wskazującego na poprzednią kopię zapasową. Było to konieczne, gdyż `git bundle` nie pozwala na stworzenie paczki, jeśli nie było żadnych zmian. Zatem najpierw sprawdzamy, czy pojawiły się jakieś commity od poprzedniej kopii bezpieczeństwa. Tylko jeśli takie były to tworzymy paczkę zawierającą zmiany. Ponownie korzystamy z `git bundle`, jednak tym razem podajemy dodatkowy argument wskazujący na konkretnę wersję repozytorium wskazaną odpowienim tagiem. Dzieki temu paczka zawiera informację tylko o zmianach, które wystąpiły później niż ta wskazana wersja repo. Potem tworzymy na nowo tag o tej samej nazwie, zapisujemy metadane oraz całość kompresujemy.

##### SVN
Zasada działania jest identyczna, jednak w sposób oczywisty musieliśmy zastąpić elementy związane z gitem na komendy związane z repozytoriami svn.

Pełne kopie tworzone są poprzez komendę `svn dump`, która w podstawowej postaci zapisuję stan całego repozytorium. Zamiast tagu, tym razem zapisujemy do pliku numer obecnej wersji repozytorium (revision number) z użyciem `svnlook youngest`. Tak samo musimy zapisać pełną ścieżkę do repozytorium oraz metadane, które względem repozytoriów git dodatkowo zawierają czas stworzenia pliku. Na koniec oczywiście wszystki pliki kompresujemy i pakujemy do archiwum poprzez użycie `tar`.

W kopiach przyrostowych tak samo najpierw sprawdzamy czy wystąpiły zmiany w repozytorium poprzez porównanie obecnego numeru wersji z wcześniej zapisaną wersją. Jeśli wystąpiły zmiany to wykonujemy kopię również z wykorzystaniem `svnadmin dump`, jednak tym razem z dodatkową opcją `--incremental`, gdzie wskazujemy zakres wersji, które mają być uwzględnione. Dzięki temu kopia zawiera zmiany tylko od poprzedniej kopii bezpieczeństwa, gdyż podajemy zakres od zapisanego numeru wersji do obecnej wersji. Dalsza część skryptu jest identyczna z tygodniową i zawiera zapis numeru wersji, ścieżki, metadanych oraz kompresję wszystkich plików.




### Crontab

