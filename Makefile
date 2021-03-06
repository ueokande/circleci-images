BUNDLES = \
  android node python ruby golang php \
  postgres mariadb mysql mongo elixir \
  jruby clojure openjdk buildpack-deps redis rust

images: $(foreach b, $(BUNDLES), $(b)/generate_images)

# make sure to mkdir /tmp/example-images first
example_images: $(foreach b, $(BUNDLES), $(b)/example_image)

# grab first Dockerfile plus a README for each image, to be used for automated builds
# clean up Dockerfiles, READMEs a bit for Docker Hub
%/example_image:
	mkdir /tmp/example-images/$(@D) && \
	cd $(@D) && find . -name Dockerfile -type f | head -1 | xargs -I{} cp -v {} /tmp/example-images/$(@D) && \
	find . -name README.md -type f | head -1 | xargs -I{} cp -v {} /tmp/example-images/$(@D) && \
	sed -i 's|DO NOT MODIFY THIS FILE.  THIS FILE HAS BEEN AUTOGENERATED|this Dockerfile is an example representing one variant of this image; please see https://github.com/circleci-public/circleci-dockerfiles for a complete list of Dockerfiles for each tag/variant of this image|g' /tmp/example-images/$(@D)/Dockerfile && \
	sed -i '1,5d' /tmp/example-images/$(@D)/README.md

publish_images: images
	find . -name Dockerfile | awk '{ print length, $0 }' | sort -n -s | cut -d" " -f2- | sed 's|/Dockerfile|/publish_image|g' | xargs -n1 make

%/generate_images:
	cd $(@D) && ./generate-images

%/publish_images: %/generate_images
	find ./$(@D) -name Dockerfile | awk '{ print length, $$0 }' | sort -n -s | cut -d" " -f2- | sed 's|/Dockerfile|/publish_image|g' | xargs -n1 make

%/publish_image: %/Dockerfile
	./shared/images/build.sh ./$(@D)/Dockerfile

%/clean:
	cd $(@D) ; rm -r images || true

clean: $(foreach b, $(BUNDLES), $(b)/clean)
