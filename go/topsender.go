package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"regexp"
	"sort"
)

type Pair struct {
	Key string
	Value uint
}
type PairList []Pair
func (p PairList) Len() int { return len(p) }
func (p PairList) Swap(i, j int) { p[i], p[j] = p[j], p[i] }
func (p PairList) Less(i, j int) bool { return p[j].Value < p[i].Value }

func main() {
	senders := make(map[string]uint)
	re := regexp.MustCompile("^(?:\\S+ ){3,4}<= ([^@ ]+@(\\S+))")

	file, err := os.Open("exim_mainlog")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		if m := re.FindStringSubmatch(scanner.Text()); len(m) > 0 {
			_, ok := senders[m[1]]
			if !ok {
				senders[m[1]] = 1
			} else {
				senders[m[1]]++
			}
		}
	}

	if err := scanner.Err(); err != nil {
		log.Fatal(err)
	}

	pairs := make(PairList, 0, len(senders))
	for k, v := range senders {
		pairs = append(pairs, Pair{k, v})
	}
	sort.Sort(pairs)

	i := 0
	for _, p := range pairs {
		fmt.Printf("%5v %v\n", p.Value, p.Key)
		if i++; i > 5 {
			break
		}
	}
}
