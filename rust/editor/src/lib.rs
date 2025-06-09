use markdown::{to_mdast, ParseOptions};


pub fn replace_text(document: &str) -> String {
    let tree = to_mdast(document, &ParseOptions::default()).unwrap();

    let a = mdast_util_to_markdown::to_markdown(&tree);

    a.unwrap_or(String::from("Failed!"))
}


pub fn tes() {
    let text = r#"
    [
        {
          "op": "insert",
          "path": [3],
          "nodes": [{ "type": "paragraph", "data": { "delta": [] } }]
        },
        {
          "op": "update",
          "path": [2],
          "attributes": { "delta": [] },
          "oldAttributes": { "delta": [] }
        }
    ]
    "#;

    /* match serde_json::from_str::<Vec<Operation>>(text) {
        Ok(node) => {
            println!("\nDeserialized Simple Node: {:#?}", node);
        }
        Err(e) => {
            eprintln!("Failed to deserialize JSON: {}", e);
        }
    } */
}

