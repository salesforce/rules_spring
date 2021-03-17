import requests

'''
This script queries GitHub to get the number of downloads of the releases of our rule.
'''

owner = "salesforce"
repo = "rules_spring"
h = {"Accept": "application/vnd.github.v3+json"}
u = f"https://api.github.com/repos/{owner}/{repo}/releases?per_page=100"
r = requests.get(u, headers=h).json()
r.reverse() # older tags first

print("GitHub download stats for releases of the Bazel Spring Boot rule:")
print("=================================================================")
for rel in r:
  if rel['assets']:
    tag = rel['tag_name']
    dls = rel['assets'][0]['download_count']
    pub = rel['published_at']
    print(f"PubDate: {pub} | Tag: {tag} | Dls: {dls} ")
