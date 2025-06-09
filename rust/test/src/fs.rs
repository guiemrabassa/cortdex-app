use std::{path::Path, time::Duration};

use notify::{poll::ScanEvent, Config, PollWatcher, RecursiveMode, Watcher};
use walkdir::WalkDir;




fn watch<P: AsRef<Path>>(path: P) -> notify::Result<()> {
    let (tx, rx) = std::sync::mpsc::channel();

    // if you want to use the same channel for both events
    // and you need to differentiate between scan and file change events,
    // then you will have to use something like this
    enum Message {
        Event(notify::Result<notify::Event>),
        Scan(ScanEvent),
    }

    let tx_c = tx.clone();
    // use the pollwatcher and set a callback for the scanning events
    let mut watcher = PollWatcher::with_initial_scan(
        move |watch_event| {
            tx_c.send(Message::Event(watch_event)).unwrap();
        },
        Config::default().with_poll_interval(Duration::from_millis(100)),
        move |scan_event| {
            tx.send(Message::Scan(scan_event)).unwrap();
        },
    )?;

    // Add a path to be watched. All files and directories at that path and
    // below will be monitored for changes.
    watcher.watch(path.as_ref(), RecursiveMode::Recursive)?;

    for res in rx {
        match res {
            Message::Event(e) => println!("Watch event {e:?}"),
            Message::Scan(e) => println!("Scan event {e:?}"),
        }
    }

    Ok(())
}



const FRONT_MATTER_MARKER: &str = "---";

/* 


fn read_note_from_file(path: String) -> anyhow::Result<()> {
    let content = std::fs::read_to_string(path)?;
    let mut header = Vec::<String>::new();

    let split: Vec<&str> = content.split(FRONT_MATTER_MARKER).collect();

    if split.len() > 1 {
        if let Some(a) = split.get(1) {
            // println!("Header: \n{}", a);
            let attr: Result<Attributes, serde_yaml::Error> = serde_yaml::from_str(a);

            match attr {
                Ok(attrs) => println!("Attributes: \n{:#?}", attrs),
                Err(err) => println!("Error parsing attributes: {}", err),
            }
        }
    }

    let mut map = HashMap::new();

    map.insert("name".to_string(), NoteAttributeValue::Text("Carlo".to_string()));

    let attr = Attributes {
        map,
    };
    
    let note = Note::new("Test".to_string(), "This is just a test".to_string());

    let sr = serde_yaml::to_string(&attr)?;

    println!("Note: \n{}", sr);



    let note_content = if content.starts_with(FRONT_MATTER_MARKER) {
        let lines = content.lines();
        let mut index = 1;

        for line in lines.skip(1) {
            index += 1;
            if line.starts_with(FRONT_MATTER_MARKER) {
               break;
            } else if !line.is_empty() {
                header.push(line.to_string());
            }
        }

        content.lines().skip(index).collect::<Vec<&str>>().join("\n")
    } else {
        content
    };

    // println!("Header: {:?}", header);
    // println!("Note Content: {}", note_content);

    Ok(())
} */


fn read_dir(path: String) {
    for entry in WalkDir::new(path).into_iter().filter_map(|e| e.ok()) {
        if let Ok(metadata) = entry.metadata() {
            println!("{}:\n{:#?}", entry.path().display(), metadata);
        }
    }
}