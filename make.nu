const repo = "nushell/nushell"

const checkouts_dir = path self checkouts
const latest_checkout_dir = path self checkouts/latest
const dev_checkout_dir = path self checkouts/dev

const docs_dir = path self docs

const target_dir = path self target
const target_doc_dir = path self target/doc

def find-latest-version [] {
    http get https://crates.io/api/v1/crates/nu 
    | get crate.max_stable_version
}

def checkouts [] {
    rm -rf $checkouts_dir
    gh repo clone $repo $latest_checkout_dir -- --depth=1 --branch (find-latest-version)
    gh repo clone $repo $dev_checkout_dir -- --depth=1 --branch main
}

export def main [] {
    checkouts

    rm -rf $docs_dir
    mkdir $docs_dir

    rm -rf $target_doc_dir
    for version in ["latest", "dev"] {
        cd ($checkouts_dir | path join $version)
        cargo doc --workspace --keep-going --no-deps --target-dir $target_dir
        mv $target_doc_dir ($docs_dir | path join $version)
    }
}
