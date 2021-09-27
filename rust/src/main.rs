use std::collections::HashMap;
use regex::Regex;
use std::fs::File;
use std::io::{BufReader, prelude::*};

fn main() {
    let mut senders = HashMap::new();
    let re = Regex::new(r"^(?:\S+ ){3,4}<= ([^ @]+@(\S+))").unwrap();
    let file = File::open("exim_mainlog").unwrap();

    for line in BufReader::new(file).lines() {
        let line = line.unwrap();
        if let Some(caps) = re.captures(&line) {
            if let Some(count) = senders.get_mut(&caps[1]) {
                *count += 1;
            } else {
                senders.insert(caps[1].to_owned(), 1);
            }
        }
    }

    let mut top = senders.iter().collect::<Vec<(&String, &u32)>>();
    top.sort_by(|a, b| b.1.cmp(&a.1));
    for (k, v) in top.iter().take(5) {
        println!("{:5} {}", v, k);
    }
}
